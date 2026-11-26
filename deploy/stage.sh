#!/usr/bin/env bash
# ==============================================================================
# CockpitNotes Staging & Packaging Tool
# ------------------------------------------------------------------------------
# Assembles the SkunkCrafts Updater staging payload for a specified channel
# (release, beta, or all), dynamically stamps the version from CockpitNotes.lua,
# optionally generates depot manifests via xpdepot.py, and optionally packages
# a clean client distribution zip.
#
# Usage:
#   ./deploy/stage.sh [release|beta|all] [--build-depot] [--package-zip] [--sync-fwl]
# ==============================================================================

set -euo pipefail

TARGET="${1:-release}"
SYNC_FWL=false
BUILD_DEPOT=false
PACKAGE_ZIP=false

for arg in "$@"; do
    if [[ "$arg" == "--sync-fwl" ]]; then
        SYNC_FWL=true
    fi
    if [[ "$arg" == "--build-depot" ]]; then
        BUILD_DEPOT=true
    fi
    if [[ "$arg" == "--package-zip" ]]; then
        PACKAGE_ZIP=true
    fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FWL_ROOT="$(cd "$REPO_ROOT/../.." && pwd)"

resolve_version() {
    local VER="${COCKPIT_NOTES_VERSION:-}"
    if [[ -z "$VER" ]]; then
        VER=$(grep 'local COCKPIT_NOTES_VERSION' "$REPO_ROOT/CockpitNotes.lua" | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
    fi
    if [[ -z "$VER" ]]; then
        echo "Error: Could not resolve COCKPIT_NOTES_VERSION from CockpitNotes.lua" >&2
        exit 1
    fi
    echo "$VER"
}

RESOLVED_VER="$(resolve_version)"

stage_channel() {
    local CHANNEL="$1"
    local CHANNEL_CFG="$REPO_ROOT/deploy/channels/${CHANNEL}_config.txt"
    if [[ ! -f "$CHANNEL_CFG" ]]; then
        echo "Error: Unknown channel configuration: $CHANNEL_CFG"
        echo "Available channels: release, beta, all"
        exit 1
    fi

    local STAGING_DIR="$REPO_ROOT/build/staging/$CHANNEL/CockpitNotes"
    echo "==> Staging CockpitNotes v${RESOLVED_VER} for channel: $CHANNEL"
    rm -rf "$STAGING_DIR"
    mkdir -p "$STAGING_DIR/notes"

    # 1. Copy runtime files directly from repository source
    cp -a "$REPO_ROOT/CockpitNotes.lua" "$STAGING_DIR/"
    cp -a "$REPO_ROOT/notes/"* "$STAGING_DIR/notes/"
    cp -a "$REPO_ROOT/changelog.txt" "$STAGING_DIR/"
    cp -a "$REPO_ROOT/readme.txt" "$STAGING_DIR/"

    # 2. Stamp resolved version onto prototype skunkcrafts_updater_config.txt & copy control lists
    sed -E "s/^version\|.*/version|${RESOLVED_VER}/" "$CHANNEL_CFG" > "$STAGING_DIR/skunkcrafts_updater_config.txt"
    echo "    [Version] Stamped version|${RESOLVED_VER} onto prototype skunkcrafts_updater_config.txt"
    cp -a "$REPO_ROOT/deploy/skunkcrafts_updater_oncelist.txt" "$STAGING_DIR/"
    cp -a "$REPO_ROOT/deploy/skunkcrafts_updater_blacklist.txt" "$STAGING_DIR/"
    if [[ -f "$REPO_ROOT/deploy/skunkcrafts_updater_ignorelist.txt" ]]; then
        cp -a "$REPO_ROOT/deploy/skunkcrafts_updater_ignorelist.txt" "$STAGING_DIR/"
    fi

    echo "==> Staging complete at: $STAGING_DIR"

    # 3. Optional: Build local depot manifests using xpdepot.py
    if [[ "$BUILD_DEPOT" == true ]]; then
        local DEPOT_DIR="$REPO_ROOT/build/depot/depot/$CHANNEL/CockpitNotes"
        echo "==> Generating depot manifests with xpdepot.py for $CHANNEL..."
        rm -rf "$DEPOT_DIR"
        python3 "$SCRIPT_DIR/xpdepot.py" --stage "$STAGING_DIR" --depot "$DEPOT_DIR"
    fi
}

if [[ "$TARGET" == "all" ]]; then
    stage_channel "release"
    stage_channel "beta"
else
    stage_channel "$TARGET"
fi

# 4. Optional: Sync client release package to FlyWithLua (only when explicitly requested)
if [[ "$SYNC_FWL" == true ]]; then
    FWL_DEST="$FWL_ROOT/FlyWithLua/Scripts/CockpitNotes"
    echo "==> Mirroring client release package to: $FWL_DEST"
    rm -rf "$FWL_DEST"
    mkdir -p "$FWL_DEST/notes"

    RELEASE_DEPOT="$REPO_ROOT/build/depot/depot/release/CockpitNotes"
    if [[ -d "$RELEASE_DEPOT" ]]; then
        cp -a "$RELEASE_DEPOT/CockpitNotes.lua" "$FWL_DEST/"
        cp -a "$RELEASE_DEPOT/notes/"* "$FWL_DEST/notes/"
        cp -a "$RELEASE_DEPOT/skunkcrafts_updater.cfg" "$FWL_DEST/"
        cp -a "$RELEASE_DEPOT/changelog.txt" "$FWL_DEST/"
        cp -a "$RELEASE_DEPOT/readme.txt" "$FWL_DEST/"
    else
        cp -a "$REPO_ROOT/CockpitNotes.lua" "$FWL_DEST/"
        cp -a "$REPO_ROOT/notes/"* "$FWL_DEST/notes/"
        sed -E "s/^version\|.*/version|${RESOLVED_VER}/" "$REPO_ROOT/deploy/channels/release_config.txt" > "$FWL_DEST/skunkcrafts_updater.cfg"
        cp -a "$REPO_ROOT/changelog.txt" "$FWL_DEST/"
        cp -a "$REPO_ROOT/readme.txt" "$FWL_DEST/"
    fi
    echo "==> FlyWithLua distribution payload synchronized successfully!"
fi

# 5. Optional: Package clean client distribution zip
if [[ "$PACKAGE_ZIP" == true ]]; then
    DIST_ROOT="$REPO_ROOT/build/dist"
    DIST_PAYLOAD="$DIST_ROOT/CockpitNotes"
    ZIP_NAME="CockpitNotes_v${RESOLVED_VER}.zip"
    echo "==> Packaging client release zip (${ZIP_NAME})..."
    rm -rf "$DIST_ROOT"
    mkdir -p "$DIST_PAYLOAD/notes"

    RELEASE_DEPOT="$REPO_ROOT/build/depot/depot/release/CockpitNotes"
    if [[ -d "$RELEASE_DEPOT" ]]; then
        cp -a "$RELEASE_DEPOT/CockpitNotes.lua" "$DIST_PAYLOAD/"
        cp -a "$RELEASE_DEPOT/notes/"* "$DIST_PAYLOAD/notes/"
        cp -a "$RELEASE_DEPOT/skunkcrafts_updater.cfg" "$DIST_PAYLOAD/"
        cp -a "$RELEASE_DEPOT/changelog.txt" "$DIST_PAYLOAD/"
        cp -a "$RELEASE_DEPOT/readme.txt" "$DIST_PAYLOAD/"
    else
        cp -a "$REPO_ROOT/CockpitNotes.lua" "$DIST_PAYLOAD/"
        cp -a "$REPO_ROOT/notes/"* "$DIST_PAYLOAD/notes/"
        sed -E "s/^version\|.*/version|${RESOLVED_VER}/" "$REPO_ROOT/deploy/channels/release_config.txt" > "$DIST_PAYLOAD/skunkcrafts_updater.cfg"
        cp -a "$REPO_ROOT/changelog.txt" "$DIST_PAYLOAD/"
        cp -a "$REPO_ROOT/readme.txt" "$DIST_PAYLOAD/"
    fi

    (cd "$DIST_ROOT" && zip -q -r "$ZIP_NAME" CockpitNotes -x "*.DS_Store" "*/.gitkeep")
    echo "==> Distribution zip packaged at: $DIST_ROOT/$ZIP_NAME"
fi
