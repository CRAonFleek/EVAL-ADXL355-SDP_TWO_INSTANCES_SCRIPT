# EVAL-ADXL355-SDP Dual-Instance Automation

This repository contains an AutoHotkey v2 script that automates data capture for two simultaneous instances of the Analog Devices EVAL‑ADXL355‑SDP evaluation software (isolated and sandboxed/Sandboxie). The script is optimized for a dual-window workflow where both instances share the same GUI layout and screen coordinates.

## Features

- Controls two EVAL-ADXL355-SDP instances at once (isolated + sandboxed).
- Automatically:
  - Scrolls to the bottom-left of each GUI to access controls.
  - Sets timestamped filenames with `Isolated_` / `Naked_` prefixes.
  - Starts and stops data capture in both instances.
  - Scrolls back up after stopping so graphs are visible.
  - Takes PNG screenshots of the graph area for each instance.
  - Saves screenshots into a matching folder structure under `Graphs\` based on the current recording path under `Recordings\`.
- Uses window titles and screen coordinates tuned for a specific layout and resolution.

## Requirements

- Windows (tested with Windows 10/11).
- AutoHotkey v2 installed.
- Analog Devices EVAL-ADXL355-SDP software installed.
- (Optional but recommended) Sandboxie/Sandboxie-Plus for running the second instance.

## Setup

1. Clone this repository and ensure the `.ahk` script is present.
2. Install AutoHotkey v2 and associate `.ahk` files with it.
3. Adjust the following in the script if they differ on your system:
   - Window titles:
     - `Producer/Consumer Design Pattern (Events)`
     - `[#] [EVAL] Producer/Consumer Design Pattern (Events) [#]`
   - Screen coordinates if your monitor resolution, scaling, or window layout is different.
4. Make sure the base project folder structure exists, for example:

   C:\Users\cemat\Desktop\Studiprojekt_Vibrationssensor\Sensor\
       Recordings\
       Graphs\

   The script will auto-create subfolders under `Graphs\` that mirror `Recordings\`.

## How it works

### Window detection

The script uses exact title matching to find both instances:

- Isolated window:
  - `Producer/Consumer Design Pattern (Events)`
- Sandboxed window:
  - `[#] [EVAL] Producer/Consumer Design Pattern (Events) [#]`

If one instance is missing, actions only apply to the window(s) that exist.

### Coordinate-based automation

The script assumes a fixed window position and uses hard-coded screen coordinates for:

- Filename field (for measurement file names).
- Path field (for the `Recordings\` directory).
- Start and Stop buttons.
- Graph region for screenshots.

Because of this, the EVAL GUI should be in a consistent size/position when using the script.

## Hotkeys

### F9 – Prepare and start measurement

For all detected instances:

1. Scrolls down and left to expose the filename field and buttons.
2. Sets a shared timestamp (for example, `20260106_131530`) for this run.
3. For each window:
   - Determines prefix:
     - `Isolated_` for the non-sandboxed instance.
     - `Naked_` for the sandboxed instance.
   - Triple-clicks the filename field and replaces it with:
     - `Isolated_<timestamp>.txt`
     - `Naked_<timestamp>.txt`
4. Clicks the **Start Data Capture** button in each window.
5. Shows a small tooltip confirming that filenames were set and capture started.

### F10 – Stop, capture graphs, and screenshot

For all detected instances:

1. Scrolls down and left to expose the **Stop** button and path field.
2. For each window:
   - Triple-clicks the path field (the directory where recordings are saved).
   - Copies the path from the field (for example, `C:\Users\...\Sensor\Recordings\Mile17\`).
   - Derives a graph path by replacing `Recordings` with `Graphs`, for example, `C:\Users\...\Sensor\Graphs\Mile17\`.
   - Stores this per-window graph path.
3. Clicks the **Stop Data Capture** button in each window.
4. Scrolls back up so that the graphs are visible again.
5. For each window:
   - Ensures the `Graphs\...` directory exists, creating it if needed.
   - Uses the run's timestamp and prefix to save a screenshot:
     - `Isolated_<timestamp>_screenshot.png`
     - `Naked_<timestamp>_screenshot.png`
   - Saves the PNG into the corresponding `Graphs\...` folder.
6. Shows a tooltip summarizing how many sensors were stopped and screenshots saved.

### Esc – Exit script

Immediately terminates the AutoHotkey script.

## Usage notes

- **Resolution/layout dependent**: The script relies on fixed screen coordinates from tools like Window Spy. If you change monitor resolution, scaling (DPI), or move/resize the EVAL windows, you may need to re-measure coordinates and update the script.
- **Sandboxie configuration**: To avoid recovery popups, configure direct access for your data folders so Sandboxie can write directly to `Recordings\` and `Graphs\`.
- **Timing**: There are deliberate `Sleep` waits to ensure the GUI has time to scroll and update before clicks or screenshots. If you see inconsistent behavior, you can slightly increase these delays.

## Customization

You may want to adjust:

- Window titles (if the EVAL software titles change or are localized).
- Base paths if your project lives somewhere else.
- Coordinates for filename field, path field, start/stop buttons, and graph capture rectangle.
- Hotkeys (`F9`, `F10`, `Esc`) to fit your workflow.

## Disclaimer

This script automates mouse and keyboard interaction with a vendor GUI. Small UI or layout changes in the EVAL software may break the automation and require updating the coordinates or logic. Use at your own risk and always verify captured data and screenshots.
