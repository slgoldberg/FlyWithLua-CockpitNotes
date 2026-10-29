# FlyWithLua Cockpit Notes & Scratchpad

> **Official Exemplar Template for SkunkCrafts Updater Subfolder Add-ons**  
> *Built for FlyWithLua 2.8.20+ and SkunkCrafts Updater v4.2.7+*

---

## 1. Pilot User Manual

**Cockpit Notes** is an in-sim electronic flight bag (EFB) scratchpad, ATIS note-taker, and live Markdown editor for X-Plane 12 and 11.

### Features
* **Three Workflow Modes:**
  * **Write:** Fullscreen, distraction-free markdown text editor.
  * **Split:** Side-by-side editing with real-time rendered preview.
  * **Preview:** Clean, formatted briefing document.
* **Tactile Canvas Font Zoom (50% to 200%):**
  * Step font size smoothly by 1 exact pixel using `[-]` and `[+]` or mouse wheel over the readout.
  * 1-click reset (`↺`) toggles between 100% baseline (16 px) and your previous zoom level.
* **Aviation Quick-Templates:**
  * **ATIS Copy Pad:** Airport, weather, altimeter, runways, and NOTAMs.
  * **IFR Clearance (CRAFT):** Clearance limit, Route, Altitude, Frequency, Transponder/Squawk with checklist confirmation.
  * **Pre-Flight Checklist:** Interactive task list.
  * **Fuel & Weight Planning:** Takeoff/landing limits, payload, FAR/ICAO fuel burn, and reserve thresholds.
  * **Diversion Briefing:** Alternate airport specs, weather minima, fuel reserves, and ATC divert checklist.
  * **METAR & TAF Scratchpad:** Decoded weather observations, terminal forecasts, and winter ops checklist.
  * **FlyWithLua Scratchpad:** Test datarefs, avionics badges, and Lua logic.
* **Multi-Note Storage & Finder Integration:**
  * Switch between notes via the top-right dropdown.
  * Click **+ New** to instantly create and name a new note.
  * Any `.md` file dropped into `Scripts/CockpitNotes/notes/` in Finder or Windows Explorer is discovered automatically.

---

## 2. Developer Blueprint: The 3-Tier SkunkCrafts Architecture

This repository serves as the official reference implementation for packaging a standalone, containerized FlyWithLua addon that automatically updates via **SkunkCrafts Updater (SCU)**.

### The 3-Tier Pipeline

```text
  LAYER 1: SOURCE REPOSITORY (This Git Repo)
  ├── CockpitNotes.lua               <-- Master Lua entry point
  ├── notes/                          <-- Starter templates
  ├── deploy/                         <-- Staging configs & tools
  │    ├── channels/
  │    │    ├── release_config.txt   <-- Module URL pointing to depot release
  │    │    ├── beta_config.txt      <-- Module URL pointing to depot beta
  │    │    └── daily_config.txt     <-- Module URL pointing to depot daily
  │    ├── skunkcrafts_updater_oncelist.txt
  │    ├── skunkcrafts_updater_blacklist.txt
  │    └── stage.sh
  └── README.md
            │
            ▼ (./deploy/stage.sh <channel>)
  LAYER 2: STAGING GROUND
  build/staging/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── skunkcrafts_updater_config.txt  <-- Server-side generator config
  └── skunkcrafts_updater_oncelist.txt
            │
            ▼ (xpdepot.py <channel> CockpitNotes update)
  LAYER 3: PUBLIC DEPOT (HTTP Server)
  depot/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── skunkcrafts_updater.cfg         <-- Client-facing manifest
  ├── skunkcrafts_updater_whitelist.txt (Oncelist files assigned CRC -1)
  └── skunkcrafts_updater_sizeslist.txt
```

### Key SkunkCrafts Developer Rules

1. **Server Config vs. Client Config:**
   * In Staging (Layer 2), the configuration file is named **`skunkcrafts_updater_config.txt`**.
   * When `xpdepot.py` publishes to the Depot (Layer 3), it translates `skunkcrafts_updater_config.txt` into **`skunkcrafts_updater.cfg`** for client consumption.
2. **Protecting User Edits via `oncelist.txt`:**
   * Files declared in `skunkcrafts_updater_oncelist.txt` (such as `notes/cockpit_notes.md`) are assigned a CRC of **`-1`** in the remote whitelist.
   * SkunkCrafts Updater installs `-1` files on first setup, but **never overwrites them during subsequent updates**, preserving the pilot's custom notes forever.
3. **No Unintentional Deletions:**
   * SkunkCrafts Updater is manifest-driven (whitelist). It never deletes unlisted local files unless they are explicitly added to `skunkcrafts_updater_blacklist.txt`.

---

## 3. Building & Staging

To stage a release for deployment to your SkunkCrafts depot:

```bash
# Stage the 'release' channel
./deploy/stage.sh release

# Stage the 'beta' channel
./deploy/stage.sh beta

# Stage release and mirror the client package to FlyWithLua/Scripts/CockpitNotes/
./deploy/stage.sh release --sync-fwl
```

Once staged, run `xpdepot.py` to synchronize the staging directory to your public depot:

```bash
./tools/xpdepot.py release CockpitNotes update
```
