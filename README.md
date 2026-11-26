# FlyWithLua Cockpit Notes & Scratchpad

> **Official Turnkey Reference Implementation for SkunkCrafts Updater Subfolder Add-ons**  
> *Built for FlyWithLua 2.8.23+ (LuiGee / ImGee) and SkunkCrafts Updater v4.2.18+*

---

## 1. Pilot User Manual

**Cockpit Notes** is an in-sim electronic flight bag (EFB) scratchpad, ATIS note-taker, and live Markdown editor for X-Plane 12 and X-Plane 11.

### Features
* **Three Workflow Modes:**
  * **Write:** Fullscreen, distraction-free markdown text editor.
  * **Split:** Side-by-side editing with real-time rendered preview.
  * **Preview:** Clean, formatted briefing document.
* **5-Theme ImGee Selector (`SelectPulldown`):**
  * Switch cleanly between **Charcoal (Default)**, **Rusty (Aviation)**, **ImGui Dark**, **ImGui Classic**, and **Paper Light** via click dropdown or mouse-wheel roll, synchronized across active FlyWithLua LuiGee windows.
* **Tactile Canvas Font Zoom (50% to 200%):**
  * Step font size smoothly by 1 exact pixel using `[-]` and `[+]` or mouse wheel over the readout.
  * 1-click reset (`↺`) toggles between 100% baseline (16 px) and your previous zoom level.
* **Aviation Quick-Templates & GFM Callouts:**
  * **ATIS Copy Pad**, **IFR Clearance (CRAFT)**, **Pre-Flight Checklist**, **IFR NavLog**, **Fuel & Weight Planning**, **Diversion Briefing**, **METAR & TAF Scratchpad**, and **FlyWithLua Scratchpad**.
  * Quick-insert menu actions for GFM callout blocks (`> [!NOTE]`, `> [!TIP]`, `> [!CAUTION]`), checklists, tables, and avionics badges.
* **Relative Asset Resolution & CommonMark Links:**
  * Opening or saving a note automatically synchronizes `imgui.MD.SetWindowBaseDir(...)` to the note's parent folder so relative images and local links resolve cleanly.
  * Clicking links automatically opens the default web browser or document viewer on macOS, Windows, and Linux.
* **Native In-Cockpit File Suite (Microsecond C++11 Scanning):**
  * **FilePickerCombo:** Fast inline toolbar dropdown scanning `notes/` with zero shell popen flashing or deadlocks.
  * **In-Cockpit Open (`Open...`) & Save As (`Save As...`) Dialogs:** Modal VR-safe file browsers with breadcrumb navigation, instant file search, and automatic `.md` extension handling.
  * **Multi-Note Storage:** Automatic file persistence in `FlyWithLua/Scripts/CockpitNotes/notes/`.

---

## 2. Developer Blueprint: The Turnkey 3-Tier Architecture

This repository serves as the official reference implementation for packaging a standalone, containerized FlyWithLua add-on that updates cleanly via **SkunkCrafts Updater (SCU 4.2.18+)** -- without requiring developers to manage private web servers, Apache/Nginx hosting, or FTP mounts.

### The 3-Tier Pipeline

```text
  LAYER 1: SOURCE REPOSITORY (This Git Repo)
  ├── CockpitNotes.lua                     <-- Master Lua entry point (COCKPIT_NOTES_VERSION)
  ├── notes/                               <-- Starter templates (protected via oncelist)
  ├── changelog.txt / readme.txt           <-- SCU Changelog & Readme tab files
  ├── deploy/                              <-- Staging configs, manifests & generator
  │    ├── channels/
  │    │    ├── release_config.txt         <-- Canonical Stable/Latest SCU 4.2.18+ config
  │    │    └── beta_config.txt            <-- Canonical Stable/Latest SCU 4.2.18+ config
  │    ├── skunkcrafts_updater_oncelist.txt
  │    ├── skunkcrafts_updater_blacklist.txt
  │    ├── stage.sh                        <-- Local/CI staging & version-stamping runner
  │    └── xpdepot.py                      <-- Manifest & CRC32 generator
  ├── .github/workflows/
  │    ├── scu_publish.yml                 <-- Manual publish (beta / release / promote+publish / both)
  │    └── scu_beta2release.yml            <-- Zero-rebuild beta -> release channel promotion
  └── README.md
            │
            ▼ (./deploy/stage.sh <channel> --build-depot)
  LAYER 2: STAGING GROUND
  build/staging/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── changelog.txt / readme.txt
  ├── skunkcrafts_updater_config.txt       <-- Version-stamped generator config
  └── skunkcrafts_updater_oncelist.txt
            │
            ▼ (deploy/xpdepot.py via GitHub Actions workflow_dispatch)
  LAYER 3: PUBLIC DEPOT (GitHub Pages / Fastly CDN on gh-pages)
  https://<username>.github.io/<repo>/depot/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── changelog.txt / readme.txt
  ├── skunkcrafts_updater.cfg              <-- Client-facing manifest
  ├── skunkcrafts_updater_whitelist.txt    (Oncelist files assigned CRC -1)
  ├── skunkcrafts_updater_sizeslist.txt
  └── skunkcrafts_updater_blacklist.txt
```

### Key SkunkCrafts Updater 4.2.18+ Rules

1. **Canonical Multi-Channel Configuration (`main_name|Stable` + `channel.Latest`):**
   * Both `release_config.txt` and `beta_config.txt` **always** set `module|` to the canonical `Stable` (`depot/release`) URL, never point `module|` to `depot/beta`, never emit `channel.release|`, and use `channel.Latest|` (avoiding `channel.beta` which collides with legacy `beta.cfg`):
     ```ini
     zone|custom
     disabled|false
     module|https://<user>.github.io/<repo>/depot/release/CockpitNotes
     name|CockpitNotes
     version|1.1.0
     locked|false
     main_name|Stable
     channel.Latest|https://<user>.github.io/<repo>/depot/beta/CockpitNotes
     changelog|changelog.txt
     ```
   * Because the channel declaration is identical in both depots, promoting `beta` to `release` is a pure wholesale directory copy on `gh-pages` (`SkunkCrafts: Copy "beta" to "release"`) with zero rebuilds or re-stamping.
2. **Explicit Manual Publishing (`workflow_dispatch`):**
   * Pushing commits to `master` does **not** automatically overwrite live user depots.
   * When ready to ship, open **Actions** on GitHub and run either:
     * **SkunkCrafts: Publish latest build...** (`scu_publish.yml`) -- publish `master` to `beta`, `release`, promote `beta->release` then publish `beta`, or publish to both, with an optional GitHub Release & ZIP.
     * **SkunkCrafts: Copy "beta" to "release"** (`scu_beta2release.yml`) -- promote the exact tested `beta` depot wholesale to `release`.
3. **Server Config vs. Client Config:**
   * In Staging (Layer 2), the prototype config file is named **`skunkcrafts_updater_config.txt`**, stamped dynamically from `COCKPIT_NOTES_VERSION` in `CockpitNotes.lua`.
   * When `xpdepot.py` builds the Depot (Layer 3), it translates `skunkcrafts_updater_config.txt` into **`skunkcrafts_updater.cfg`** for client consumption.
4. **Protecting User Edits via `oncelist.txt`:**
   * Files declared in `skunkcrafts_updater_oncelist.txt` (such as `notes/cockpit_notes.md`) are assigned a CRC of **`-1`** in the remote whitelist.
   * SkunkCrafts Updater installs `-1` files on first setup, but **never overwrites them during subsequent updates**, preserving the pilot's custom notes.

---

## 3. How to Use this as a Template for Your Add-on

1. **Use this template:** Click **Use this template** or fork this repository on GitHub.
2. **Configure GitHub Pages:**
   * In your repo settings: **Settings -> Pages -> Build and deployment -> Source: Deploy from a branch (`gh-pages` / root)**.
   * Update `module|` and `channel.Latest|` in `deploy/channels/release_config.txt` and `deploy/channels/beta_config.txt` to point to your GitHub username and repository.
3. **Publish via GitHub Actions:**
   * Push your changes to `master`, then trigger **SkunkCrafts: Publish latest build...** from the **Actions** tab.
4. **Test locally (Optional):**
   ```bash
   # Stage and generate depot manifests locally for both channels
   ./deploy/stage.sh all --build-depot

   # Package a clean client release zip locally
   ./deploy/stage.sh release --build-depot --package-zip
   ```
