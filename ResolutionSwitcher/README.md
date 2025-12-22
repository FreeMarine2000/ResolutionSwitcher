# 🖥️ Resolution Switcher

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-000000.svg?style=flat&logo=apple" alt="macOS" />
  <img src="https://img.shields.io/badge/Language-Swift%205-F05138.svg?style=flat&logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20AppKit-blue.svg?style=flat" alt="SwiftUI" />
</p>

**Resolution Switcher** is a powerful native macOS utility designed to force custom display resolutions on internal and external monitors. It excels at handling difficult HiDPI and 16:10 aspect ratios that standard System Settings often hide.

It utilizes a **Hybrid Resolution Engine** that prioritizes native Apple Core Graphics APIs for speed, while seamlessly falling back to `displayplacer` for complex Retina scaling and stubborn external displays.

---

## 🚀 Features

### ⚡ Dynamic Resolution Discovery
Unlike standard tools that rely on hardcoded presets, Resolution Switcher directly queries your GPU to find **every valid resolution** your monitor supports.
* **Plug & Play:** Automatically detects capabilities for MacBook Air (M2/M3), MacBook Pro (14"/16"), and 4K external monitors.
* **Smart Filtering:** Hides duplicate or unusable frequencies to keep the list clean.

### 🔌 Multi-Monitor Support
* **Targeted Control:** Select specifically which monitor (Internal vs. External) you want to modify using the dropdown selector.
* **Independent Scaling:** Apply different scaling rules to your laptop screen while keeping your external monitor native.

### 🛠 Hybrid Engine (Native + CLI)
1.  **Stage 1 (Native):** Attempts to switch using `CoreGraphics` (CGDisplay). This is instant and flicker-free.
2.  **Stage 2 (Fallback):** If the OS resists (common with non-standard HiDPI scaling), it invokes the embedded `displayplacer` engine to force the mode via shell command.

### 📝 Integrated Debugging
* **Live Logs:** Built-in log viewer to track success/failure states.
* **Error Reporting:** Clear explanations when a resolution is rejected by hardware (e.g., "Invalid Refresh Rate").

---

## ⚙️ How It Works

The app operates using a robust `ResolutionManager` singleton:
1.  **Discovery:** On launch, it iterates through `NSScreen.screens` to map Display IDs.
2.  **Validation:** It fetches `CGDisplayCopyAllDisplayModes` to build a safe list of available resolutions.
3.  **Execution:** When you click a resolution:
    * It calculates the perfect 16:10 aspect ratio (if needed) to prevent black bars.
    * It attempts the switch natively.
    * If native fails, it executes a safe shell command to force the change.

---


## 📥 Installation & Build

### Prerequisites
* macOS 12.0+ (Monterey or newer)
* Xcode 14+ (for building from source)
* **Recommended:** Install `displayplacer` for maximum compatibility:
    ```bash
    brew install displayplacer
    ```

### Option 1: Build from Source (Recommended)
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/FreeMarine2000/ResolutionSwitcher.git](https://github.com/FreeMarine2000/ResolutionSwitcher.git)
    cd ResolutionSwitcher
    ```
2.  **Open in Xcode:**
    Double-click `ResolutionSwitcher.xcodeproj`.
3.  **Build & Run:**
    Press `Cmd + R` to run locally, or `Product > Archive` to build a standalone app.

---

## 🛠 Troubleshooting

**"The resolution didn't change!"**
* Check the **Logs** button in the app.
* If you see "Mode not found," try using the **Custom Input** fields at the bottom to force specific dimensions.

**"The app keeps running in the dock."**
* This is intended behavior. Use `Cmd + Q` or the "Quit" button in the menu bar to fully terminate the process.

---

## 🤝 Contributing
Contributions are welcome! Feel free to fork the repository and submit a Pull Request.
## 📜 Changelog

### v1.3.0 (Initial Release)
* **Hybrid Engine:** implemented dual-stage resolution switching (CoreGraphics + `displayplacer` fallback).
* **Multi-Monitor Support:** Added dynamic detection and targeting for specific Display IDs (Internal vs. External).
* **System Integration:** Added proper macOS Dock behavior, Menu Bar shortcuts (Cmd+Q), and custom App Icon.
* **Debugging:** Integrated `AppLogger` for real-time error tracking and log file export.
* **UI:** Clean SwiftUI interface with native window management and custom input overrides.

## 📄 License
This project is open-source. Feel free to use and modify it for your own workflows.
