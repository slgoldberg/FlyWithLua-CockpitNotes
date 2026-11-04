# Cockpit Notes & Scratchpad

![FlyWithLua](https://img.shields.io/badge/FlyWithLua-Phase_3_Suite-blue) ![X-Plane 12](https://img.shields.io/badge/Simulator-X--Plane_12-informational) ![Status](https://img.shields.io/badge/Status-Active-brightgreen)

Welcome to **Cockpit Notes** for FlyWithLua!

## Quick Start
* **Modes:** Use the toolbar above to switch between **Write** (distraction-free editor), **Split** (side-by-side editing and live rendered preview), and **Preview** (clean briefing document).
* **Zoom:** Use `[-]` and `[+]` or the mouse wheel in the header to dynamically zoom text from **50% to 200%**. Click `↺` to toggle between 100% baseline and your previous zoom.
* **Aviation Templates:** Click the dropdown above to load pre-formatted checklists, ATIS copy pads, navigation logs, and fuel calculations.
* **In-Cockpit File Management:** Switch notes with the native `Note:` dropdown, or click **Open...** and **Save As...** to manage flight notes anywhere in-sim.
* **Interactive GFM Tables:** Standard markdown tables (`| Col 1 | Col 2 |`) support resizable columns and column sorting!
* **Async Remote Badges & Images:** Badges and online charts load smoothly in the background without frame drops.
* **Avionics Annunciators & Icons:** Live annunciator capsules with embedded vector icons:
  * Autopilot: <pill icon=avionics_beacon color=#3498db>NAV / ALT</pill>
  * Transponder: <pill icon=avionics_beacon color=#2ecc71>ALT (Mode C)</pill>
  * Pitot Heat: <pill icon=avionics_beacon orange>ON</pill>
  * Master Warning: <pill icon=avionics_beacon color=#e74c3c />
  * Firmware: <badge icon=avionics_beacon>v2.3.0</badge>

---

### Flight Progress Overview
| Fix / Point | Altitude | Distance | ETE | Fuel Rem | Status |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **KORD** (Dep) | Field | 0 NM | 00:00 | 18,800 lbs | <badge icon=avionics_beacon green>DEPARTED</badge> |
| **JOT** (VOR) | 5,000 | 28 NM | 00:07 | 17,900 lbs | <pill icon=avionics_beacon color=#2ecc71>PASSED</pill> |
| **BAE** (VOR) | FL240 | 64 NM | 00:15 | 16,200 lbs | <pill icon=avionics_beacon color=#2ecc71>PASSED</pill> |
| **DLL** (VOR) | FL340 | 78 NM | 00:18 | 14,800 lbs | <pill icon=avionics_beacon color=#3498db>ACTIVE</pill> |
| **KMSP** (Dest) | Field | 142 NM | 00:32 | 9,400 lbs | <badge icon=avionics_beacon yellow>PLANNED</badge> |

---

### Flight Notes & Checklist
- `[ ]` Departure clearance copied & verified
- `[ ]` Altimeter set & cross-checked
- `[ ]` Departure runway confirmed
