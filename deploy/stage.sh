#!/usr/bin/env bash
# ==============================================================================
# CockpitNotes Staging & Packaging Tool
# ------------------------------------------------------------------------------
# Assembles the 3-tier SkunkCrafts staging payload for a specified channel,
# and optionally mirrors the release client package into FlyWithLua/Scripts/.
#
# Usage:
#   ./deploy/stage.sh [release|beta|daily] [--sync-fwl]
# ==============================================================================

set -euo pipefail

CHANNEL="${1:-release}"
SYNC_FWL=false

for arg in "$@"; do
    if [[ "$arg" == "--sync-fwl" ]]; then
        SYNC_FWL=true
    fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FWL_ROOT="$(cd "$REPO_ROOT/../.." && pwd)"

CHANNEL_CFG="$REPO_ROOT/deploy/channels/${CHANNEL}_config.txt"
if [[ ! -f "$CHANNEL_CFG" ]]; then
    echo "Error: Unknown channel configuration: $CHANNEL_CFG"
    echo "Available channels: release, beta, daily"
    exit 1
fi

STAGING_DIR="$REPO_ROOT/build/staging/$CHANNEL/CockpitNotes"
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

# 3. Optional: Sync client release package to FlyWithLua
if [[ "$SYNC_FWL" == true ]]; then
    FWL_DEST="$FWL_ROOT/FlyWithLua/Scripts/CockpitNotes"
    echo "==> Mirroring client release package to: $FWL_DEST"
    rm -rf "$FWL_DEST"
    mkdir -p "$FWL_DEST/notes"
    cp -a "$REPO_ROOT/CockpitNotes.lua" "$FWL_DEST/"
    cp -a "$REPO_ROOT/notes/"* "$FWL_DEST/notes/"
    
    # In FlyWithLua distribution, the client config is named skunkcrafts_updater.cfg
    cp -a "$REPO_ROOT/deploy/channels/release_config.txt" "$FWL_DEST/skunkcrafts_updater.cfg"
    echo "==> FlyWithLua distribution payload synchronized successfully!"
fi
