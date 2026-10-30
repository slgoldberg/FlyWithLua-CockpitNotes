# FlyWithLua Cockpit Notes & Scratchpad

> **Official Turnkey Reference Implementation for SkunkCrafts Updater Subfolder Add-ons**  
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
* **Dual-Bracket CommonMark Markdown Links:**
  * Standard CommonMark `[Label](url)` and `![Alt](img)` hyperlinks supported side-by-side with legacy `{...}` syntax.
  * Clicking links automatically opens default web browser in macOS, Windows, and Linux.
* **Native In-Cockpit File Suite (Microsecond C++11 Scanning):**
  * **FilePickerCombo:** Fast inline toolbar dropdown scanning `notes/` directory with zero shell popen flashing or deadlocks.
  * **In-Cockpit Open Dialog (`Open...`):** Modal VR-safe file browser with breadcrumb navigation and instant file search.
  * **In-Cockpit Save As Dialog (`Save As...`):** Modal file saver with automatic extension enforcement.
  * **Multi-Note Storage:** Automatic file persistence in `FlyWithLua/Scripts/CockpitNotes/notes/`. Instant `+ New` note creation.

---

## 2. Developer Blueprint: The Turnkey 3-Tier Architecture

This repository serves as the official reference implementation for packaging a standalone, containerized FlyWithLua addon that automatically updates via **SkunkCrafts Updater (SCU)** -- without requiring developers to manage private web servers, Apache/Nginx hosting, or NFS mounts.

### The 3-Tier Pipeline

```text
  LAYER 1: SOURCE REPOSITORY (This Git Repo)
  ├── CockpitNotes.lua               <-- Master Lua entry point
  ├── notes/                          <-- Starter templates
  ├── deploy/                         <-- Staging configs, manifests & generator
  │    ├── channels/
  │    │    ├── release_config.txt   <-- Module URL pointing to GitHub Pages depot
  │    │    ├── beta_config.txt
  │    │    └── daily_config.txt
  │    ├── skunkcrafts_updater_oncelist.txt
  │    ├── skunkcrafts_updater_blacklist.txt
  │    ├── stage.sh                  <-- Local/CI staging runner
  │    └── xpdepot.py                <-- Manifest & CRC32 generator
  ├── .github/workflows/
  │    └── deploy-depot.yml          <-- Automated GitHub Pages depot publisher
  └── README.md
            │
            ▼ (./deploy/stage.sh all --build-depot)
  LAYER 2: STAGING GROUND
  build/staging/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── skunkcrafts_updater_config.txt  <-- Server-side generator config
  └── skunkcrafts_updater_oncelist.txt
            │
            ▼ (deploy/xpdepot.py or GitHub Actions CI)
  LAYER 3: PUBLIC DEPOT (GitHub Pages / Fastly CDN)
  https://<username>.github.io/<repo>/depot/<channel>/CockpitNotes/
  ├── CockpitNotes.lua
  ├── notes/
  ├── skunkcrafts_updater.cfg         <-- Client-facing manifest
  ├── skunkcrafts_updater_whitelist.txt (Oncelist files assigned CRC -1)
  └── skunkcrafts_updater_sizeslist.txt
```

### Key SkunkCrafts Developer Rules

1. **Turnkey Hosting via GitHub Pages:**
   * No web servers or FTP credentials needed.
   * On every push to `master` (or git tag `v*`), GitHub Actions runs `deploy/xpdepot.py` headlessly, builds the depot manifests for all channels, and deploys to the `gh-pages` branch.
   * SkunkCrafts Updater downloads updates directly over HTTPS from GitHub Pages.
2. **Modern Multi-Channel Configuration (`channel.<name>`):**
   * Multiple channels (`Main`, `beta`, `daily`, etc.) are declared directly inside the single `skunkcrafts_updater.cfg` file:
     ```text
     module|https://<user>.github.io/<repo>/depot/release/CockpitNotes
     name|CockpitNotes
     version|1.0.0
     locked|false
     channel.beta|https://<user>.github.io/<repo>/depot/beta/CockpitNotes
     # Optional: add extra channels as desired (e.g. channel.daily|...)
     ```
   * The SkunkCrafts Updater client detects these keys and exposes an interactive **Channel** dropdown (`Main`, `beta`) directly in the desktop GUI.
   * Users switch channels with a single click in the app without editing text files.
3. **Server Config vs. Client Config:**
   * In Staging (Layer 2), the configuration file is named **`skunkcrafts_updater_config.txt`**.
   * When `xpdepot.py` publishes to the Depot (Layer 3), it translates `skunkcrafts_updater_config.txt` into **`skunkcrafts_updater.cfg`** for client consumption.
4. **Protecting User Edits via `oncelist.txt`:**
   * Files declared in `skunkcrafts_updater_oncelist.txt` (such as `notes/cockpit_notes.md`) are assigned a CRC of **`-1`** in the remote whitelist.
   * SkunkCrafts Updater installs `-1` files on first setup, but **never overwrites them during subsequent updates**, preserving the pilot's custom notes forever.
5. **No Unintentional Deletions:**
   * SkunkCrafts Updater is manifest-driven (whitelist). It never deletes unlisted local files unless they are explicitly added to `skunkcrafts_updater_blacklist.txt`.

---

## 3. How to Use this as a Template for Your Addon

1. **Use this template:** Click **Use this template** or fork this repository on GitHub.
2. **Configure your GitHub Pages depot:**
   * In your repo settings: **Settings $\rightarrow$ Pages $\rightarrow$ Build and deployment $\rightarrow$ Source: Deploy from a branch (`gh-pages` / root)**.
   * Edit `deploy/channels/release_config.txt` to point to your GitHub username:
     ```text
     module|https://<your-username>.github.io/<your-repo>/depot/release/<AddonName>
     name|<AddonName>
     version|1.0.0
     locked|false
     channel.beta|https://<your-username>.github.io/<your-repo>/depot/beta/<AddonName>
     ```
3. **Push to GitHub:**
   * Push your changes or push a version tag (`git tag v1.0.0 && git push origin v1.0.0`).
   * GitHub Actions runs `.github/workflows/deploy-depot.yml`, runs `xpdepot.py` for all channels, and publishes your public depot automatically to GitHub Pages.
4. **Test locally (Optional):**
   ```bash
   # Stage and generate depot manifests locally for all channels
   ./deploy/stage.sh all --build-depot

   # Stage and synchronize into local FlyWithLua for testing in X-Plane
   ./deploy/stage.sh all --build-depot --sync-fwl
   ```
