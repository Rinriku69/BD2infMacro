
# Brown Dust 2 Infinite Reroll - AutoHotKey Macro 📜

An AutoHotKey (AHK) macro for automating the **Infinite Draw** in Brown Dust 2. This version utilizes **GDI+** for fast and accurate image searching in the background.

## 📂 Included Scripts

This repository contains two main scripts depending on your goal:

1.  **`reroll_num.ahk`**: Stops rerolling only when a specific **Number** of 5-star characters appear in a single pull (e.g., finding 4 five-stars).
2.  **`reroll_char.ahk`**: Stops rerolling when a **Specific Target Character** appears (and optionally checks for a 5-star count).

## 🚀 Features
- **Fast Image Search:** Uses `Gdip_All.ahk` for efficient screen scanning.
- **Visual Debugging:** Press `F8` to visually verify if the script sees the slots correctly (draws rectangles on screen).
- **Flexible Configuration:** Easily adjust image variation tolerances and slot positions.
- **Audio Notification:** Plays a sound file upon success.

## 🛠️ Prerequisites
- [AutoHotkey v1.1](https://www.autohotkey.com/) installed.
- The game running in a resolution matching the coordinates set in the script (default coordinates are based on 1920x1080 maximized or specifically windowed).

## ⚙️ Setup & Usage

1.  Ensure `Gdip_All.ahk` is in the same folder as the scripts.
2.  **Update Images:**
    - Replace `target.png` or `target3.png` in the `pool/` folder with a crop of the character you want to find.
3.  **Update Coordinates:**
    - Right-click the `.ahk` file and select **Edit**.
    - Modify the `=== CONFIGURABLE SETTINGS ===` section (Coordinates for Draw button, Skip button, and Slots) to match your screen.
4.  **Run the Script:**
    - Double-click `reroll_char.ahk` (or `reroll_num.ahk`).
    - Go to the game window.
    - Press **`F9`** to Start/Stop the auto-puller.

## 🔧 Troubleshooting / Debugging

If the script isn't detecting characters:
1.  Open the game to the result screen.
2.  Press **`F8`**.
3.  The script will attempt to find an image in a specific slot and show a **Green Box** (Found) or **Red Box** (Not Found).
4.  Use this to adjust your `imageSearchVariation` or `Coordinates`.

## ⚠️ Disclaimer
This macro is provided "as is" for educational purposes. Using automation software in online games may violate the Terms of Service.
