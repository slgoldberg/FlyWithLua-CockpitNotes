#!/usr/bin/env bash
# ==============================================================================
# CockpitNotes Staging & Packaging Tool
# ------------------------------------------------------------------------------
# Assembles the 3-tier SkunkCrafts staging payload for a specified channel (or all),
# optionally generates depot manifests via xpdepot.py, and optionally mirrors
# the release client package into FlyWithLua/Scripts/.
#
# Usage:
#   ./deploy/stage.sh [release|beta|daily|all] [--build-depot] [--sync-fwl]
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

stage_channel() {
    local CHANNEL="$1"
    local CHANNEL_CFG="$REPO_ROOT/deploy/channels/${CHANNEL}_config.txt"
    if [[ ! -f "$CHANNEL_CFG" ]]; then
        echo "Error: Unknown channel configuration: $CHANNEL_CFG"
        echo "Available channels: release, beta, daily, all"
        exit 1
    fi

    local STAGING_DIR="$REPO_ROOT/build/staging/$CHANNEL/CockpitNotes"
    echo "==> Staging CockpitNotes for channel: $CHANNEL"
    rm -rf "$STAGING_DIR"
    mkdir -p "$STAGING_DIR/notes"

    # 1. Copy runtime files
    cp -a "$REPO_ROOT/CockpitNotes.lua" "$STAGING_DIR/"
    cp -a "$REPO_ROOT/notes/"* "$STAGING_DIR/notes/"

    # 2. Copy SkunkCrafts server/depot generator configuration
    cp -a "$CHANNEL_CFG" "$STAGING_DIR/skunkcrafts_updater_config.txt"
    cp -a "$REPO_ROOT/deploy/skunkcrafts_updater_oncelist.txt" "$STAGING_DIR/"
    cp -a "$REPO_ROOT/deploy/skunkcrafts_updater_blacklist.txt" "$STAGING_DIR/"

    echo "==> Staging complete at: $STAGING_DIR"

    # 3. Optional: Build local depot manifests using xpdepot.py
    if [[ "$BUILD_DEPOT" == true ]]; then
        local DEPOT_DIR="$REPO_ROOT/build/depot/depot/$CHANNEL/CockpitNotes"
        echo "==> Generating depot manifests with xpdepot.py for $CHANNEL..."
        python3 "$SCRIPT_DIR/xpdepot.py" --stage "$STAGING_DIR" --depot "$DEPOT_DIR"
    fi
}

if [[ "$TARGET" == "all" ]]; then
    stage_channel "release"
    stage_channel "beta"
else
    stage_channel "$TARGET"
fi

# 4. Optional: Sync client release package to FlyWithLua
if [[ "$SYNC_FWL" == true ]]; then
    FWL_DEST="$FWL_ROOT/FlyWithLua/Scripts/CockpitNotes"
    echo "==> Mirroring client release package to: $FWL_DEST"
    rm -rf "$FWL_DEST"
    mkdir -p "$FWL_DEST/notes"
    
    # Mirror directly from the generated release depot payload if available
    RELEASE_DEPOT="$REPO_ROOT/build/depot/depot/release/CockpitNotes"
    if [[ -d "$RELEASE_DEPOT" ]]; then
        cp -a "$RELEASE_DEPOT/CockpitNotes.lua" "$FWL_DEST/"
        cp -a "$RELEASE_DEPOT/notes/"* "$FWL_DEST/notes/"
        cp -a "$RELEASE_DEPOT/skunkcrafts_updater.cfg" "$FWL_DEST/"
    else
        cp -a "$REPO_ROOT/CockpitNotes.lua" "$FWL_DEST/"
        cp -a "$REPO_ROOT/notes/"* "$FWL_DEST/notes/"
        cp -a "$REPO_ROOT/deploy/channels/release_config.txt" "$FWL_DEST/skunkcrafts_updater.cfg"
    fi
    echo "==> FlyWithLua distribution payload synchronized successfully!"
fi

# 5. Optional: Package clean client distribution zip
if [[ "$PACKAGE_ZIP" == true ]]; then
    DIST_ROOT="$REPO_ROOT/build/dist"
    DIST_PAYLOAD="$DIST_ROOT/CockpitNotes"
    echo "==> Packaging client release zip..."
    rm -rf "$DIST_ROOT"
    mkdir -p "$DIST_PAYLOAD/notes"

    RELEASE_DEPOT="$REPO_ROOT/build/depot/depot/release/CockpitNotes"
    if [[ -d "$RELEASE_DEPOT" ]]; then
        cp -a "$RELEASE_DEPOT/CockpitNotes.lua" "$DIST_PAYLOAD/"
        cp -a "$RELEASE_DEPOT/notes/"* "$DIST_PAYLOAD/notes/"
        cp -a "$RELEASE_DEPOT/skunkcrafts_updater.cfg" "$DIST_PAYLOAD/"
    else
        cp -a "$REPO_ROOT/CockpitNotes.lua" "$DIST_PAYLOAD/"
        cp -a "$REPO_ROOT/notes/"* "$DIST_PAYLOAD/notes/"
        cp -a "$REPO_ROOT/deploy/channels/release_config.txt" "$DIST_PAYLOAD/skunkcrafts_updater.cfg"
    fi

    cd "$DIST_ROOT"
    zip -q -r "CockpitNotes-release.zip" CockpitNotes
    echo "==> Distribution zip packaged at: $DIST_ROOT/CockpitNotes-release.zip"
fi
