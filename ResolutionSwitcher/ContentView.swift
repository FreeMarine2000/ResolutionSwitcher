import SwiftUI
import AppKit

struct ContentView: View {
    @State private var screenID: String? = nil
    @State private var scalingModes: [String: Bool] = [:]  // resString -> needs scaling
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("🖥 Resolution Switcher")
                .font(.title2)
                .padding(.bottom, 10)

            Button("⚡ AAA Default (1920×1200)") {
                runDisplayPlacer(width: 1920, height: 1200)
            }
            .buttonStyle(.borderedProminent)

            Button("🎮 Smooth (1512×982)") {
                runDisplayPlacer(width: 1512, height: 982)
            }
            .buttonStyle(.borderedProminent)

            Button("🎬 Cinematic (2048×1330)") {
                runDisplayPlacer(width: 2048, height: 1330)
            }
            .buttonStyle(.borderedProminent)

            Button("🔋 Battery Saver (1280×832)") {
                runDisplayPlacer(width: 1280, height: 832)
            }
            .buttonStyle(.borderedProminent)

            Divider().padding(.vertical, 5)

            Button("🔄 Reset to macOS Default (1512×982)") {
                runDisplayPlacer(width: 1512, height: 982)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 330, height: 370)
        .onAppear {
            if !displayplacerExists() {
                alertMessage = "❌ displayplacer not found in app bundle.\nPlease reinstall the app."
                showAlert = true
            } else {
                self.screenID = fetchScreenID()
                self.scalingModes = fetchScalingModes()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Resolution Switcher"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Helpers

    func bundledDisplayplacerPath() -> String? {
        if let path = Bundle.main.path(forResource: "displayplacer", ofType: nil) {
            print("✅ Using bundled displayplacer at: \(path)")
            return path
        } else {
            print("❌ No bundled displayplacer found in Resources")
            return nil
        }
    }

    func runDisplayPlacer(width: Int, height: Int) {
        guard let screenID = screenID else {
            alertMessage = "❌ No screen ID found."
            showAlert = true
            return
        }

        let resString = "\(width)x\(height)"
        let needsScaling = scalingModes[resString] ?? false
        let scalingFlag = needsScaling ? " scaling:on" : ""

        guard let bundledPath = bundledDisplayplacerPath() else {
            alertMessage = "❌ displayplacer not found in app bundle."
            showAlert = true
            return
        }

        print("👉 Running displayplacer with command: \(bundledPath) id:\(screenID) res:\(resString)\(scalingFlag)")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: bundledPath)
        process.arguments = ["id:\(screenID) res:\(resString)\(scalingFlag)"]

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                alertMessage = "✅ Switched to \(resString)\(needsScaling ? " (scaled)" : "")"
            } else {
                alertMessage = "⚠️ Failed to apply resolution \(resString)"
            }
        } catch {
            alertMessage = "❌ Error running displayplacer: \(error.localizedDescription)"
        }

        showAlert = true
    }

    func fetchScreenID() -> String? {
        guard let bundledPath = bundledDisplayplacerPath() else { return nil }

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: bundledPath)
        process.arguments = ["list"]
        process.standardOutput = pipe

        do { try process.run(); process.waitUntilExit() } catch { return nil }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if let match = output.split(separator: "\n").first(where: { $0.contains("Persistent screen id") }) {
            let parts = match.split(separator: " ")
            if parts.count > 3 { return String(parts[3]) }
        }
        return nil
    }

    func fetchScalingModes() -> [String: Bool] {
        var map: [String: Bool] = [:]
        guard let bundledPath = bundledDisplayplacerPath() else { return map }

        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: bundledPath)
        process.arguments = ["list"]
        process.standardOutput = pipe

        do { try process.run(); process.waitUntilExit() } catch { return map }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        for line in output.split(separator: "\n") {
            if line.contains("res:") {
                let parts = line.split(separator: " ")
                if let resPart = parts.first(where: { $0.starts(with: "res:") }) {
                    let resString = resPart.replacingOccurrences(of: "res:", with: "")
                    let needsScaling = line.contains("scaling:on")
                    map[resString] = needsScaling
                }
            }
        }
        return map
    }

    func displayplacerExists() -> Bool {
        return bundledDisplayplacerPath() != nil
    }
}
