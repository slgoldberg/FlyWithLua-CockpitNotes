# METAR & TAF Weather Scratchpad

* **Flight:** `KORD -> KMSP` | **Briefing Time:** `1850Z`
* **Flight Category:** ORD <badge green>VFR</badge> | MSP <badge yellow>MVFR</badge>

---

## Departure Weather (KORD)
```text
KORD 281851Z 28014G21KT 10SM BKN045 OVC090 12/03 A3012 RMK AO2 SLP201
```
* **Station & Time:** `KORD (Chicago O'Hare)` @ `18:51 UTC`
* **Wind:** `280° at 14 kt, gusts to 21 kt`
* **Visibility:** `10 Statute Miles (Unrestricted)`
* **Clouds / Ceiling:** `Broken 4,500 ft AGL, Overcast 9,000 ft AGL`
* **Temperature / Dew Point:** `12°C / 03°C` (Spread: `9°C`)
* **Altimeter (QNH):** <pill green>30.12 inHg (1020 hPa)</pill>
* **Active Runways:** `28C, 28R` (Departures)

---

## Destination Weather (KMSP)
```text
KMSP 281853Z 33018G26KT 4SM -SN BLSN BKN015 OVC030 M02/M06 A2988 RMK AO2
```
* **Station & Time:** `KMSP (Minneapolis-St. Paul)` @ `18:53 UTC`
* **Wind:** `330° at 18 kt, gusts to 26 kt`
* **Visibility:** `4 Statute Miles in Light Snow & Blowing Snow (-SN BLSN)`
* **Ceiling & Sky:** `Broken 1,500 ft AGL (Ceiling), Overcast 3,000 ft AGL`
* **Temperature / Dew Point:** `-02°C / -06°C`
* **Altimeter (QNH):** <pill blue>29.88 inHg (1012 hPa)</pill>
* **Surface Condition:** Contaminated runway; braking action Medium

---

## Destination Forecast (TAF Copy Pad)
```text
TAF KMSP 281720Z 2818/2924 34016G24KT 4SM -SN BKN018 OVC035
  TEMPO 2819/2823 2SM -SN BKN010
  FM290200 32012KT 6SM NSW BKN025
  FM291200 29010KT P6SM SKC
```
* **Arrival Trend (19:00Z - 21:00Z):** `TEMPO 2SM in light snow, ceiling 1,000 ft AGL`
* **Runway In Use:** Expect `Runway 30L / 30R` (ILS Cat I / Cat II available)
* **Crosswind Calculation:** `340° vs 300° runway heading = 40° angle @ 16G24kt (~15kt X-Wind)`

---

## Weather Verification Checklist
- `[ ]` Destination altimeter copied: `29.88 inHg`
- `[ ]` Engine & wing anti-ice requirements briefed for descent into freezing clouds
- `[ ]` Approach category and minima briefed for ILS 30L/30R
- `[ ]` Cold temperature altitude corrections applied if airport temp < 0°C
