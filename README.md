🖥 Resolution Switcher
Resolution Switcher is a lightweight macOS utility built with SwiftUI and AppKit. It allows users to quickly switch between display resolutions, offering optimized presets for gaming, cinematic viewing, and battery saving, along with a custom resolution input.

It uses a Hybrid Resolution Engine that prioritizes native macOS Core Graphics APIs for speed, while seamlessly falling back to displayplacer for complex HiDPI scaling and Retina management.

🚀 Features
⚡ Smart Presets: One-click switching to common workflows:

AAA Default: 1920×1200 (Balanced)

Smooth/Performance: 1512×982 (High FPS gaming)

Cinematic: 2048×1330 (Movie consumption)

Battery Saver: 1280×832 (Low power draw)

🤖 Custom Resolutions: Input any specific width/height.

Hybrid Engine: * Tries Native Core Graphics first (Instant switch).

Falls back to displayplacer if native switching fails (Handles difficult HiDPI/Scaling scenarios).

Safety Checks: Verifies screen availability and supported modes before applying changes to prevent black screens.

🛠 Recent Updates & Fixes
✅ Critical Bug Fixes (Latest Patch)

Fixed App Crash: Resolved a critical issue where the app would force-crash upon launch or when selecting specific modes due to improper nil-value handling in the resolution manager.

Fixed Downscaling Issue: Addressed a bug where the display refused to "descale" or switch to lower resolutions (e.g., switching from 1920p to 1280p for Battery Saver mode). The engine now correctly identifies and applies lower-bandwidth modes.

⚙️ How It Works
The app operates using a ResolutionManager singleton:

Native Attempt: It first queries the CGDisplayCopyAllDisplayModes API to see if the requested pixel dimensions exist natively on the monitor.

Fallback: If the exact pixel match isn't found (common with Retina scaling points vs. pixels), it invokes the bundled displayplacer CLI tool to force the scaled resolution.

Validation: It confirms the switch was successful and alerts the user; otherwise, it provides a descriptive error message.

## 📥 Downloads & Installation

### Option 1: Download the App (Easiest)
You can download the ready-to-use application directly from the **[Releases Page](https://github.com/FreeMarine2000/ResolutionSwitcher/releases)**.

1.  Download `ResolutionSwitcher.zip`.
2.  Unzip the file to get `ResolutionSwitcher.app`.
3.  Drag the app into your **Applications** folder.
4.  *Note:* Since this is a developer tool not signed by the App Store, you may need to right-click the app and select **Open** the first time you run it.

### Option 2: Build from Source
If you want to modify the code or build it yourself:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/FreeMarine2000/ResolutionSwitcher.git](https://github.com/FreeMarine2000/ResolutionSwitcher.git)
    ```
2.  **Open in Xcode:** Double-click `ResolutionSwitcher.xcodeproj`.
3.  **Build & Run:** Press `Cmd + R` to run on your local machine.

🤝 Contributing
Contributions are welcome! If you find a bug or want to add a new feature (like multi-monitor support), feel free to fork the repo and submit a Pull Request.

📝 License

This project is open-source. Feel free to use and modify it for your own workflows.
