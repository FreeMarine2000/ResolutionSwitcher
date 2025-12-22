import SwiftUI
import AppKit

struct ContentView: View {
    @State private var screenID: String? = nil
    @State private var scalingModes: [String: Bool] = [:]  // resString -> needs scaling
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showCustomResolution = false // Controls the pop-up
    // Replace your old 'screenID' string with these:
    @State private var availableMonitors: [MonitorInfo] = []
    @State private var selectedMonitorID: CGDirectDisplayID? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("🖥 Resolution Switcher")
                            .font(.title2)
                        
                        // 👇 NEW: Monitor Picker
                        if !availableMonitors.isEmpty {
                            Picker("Select Screen", selection: $selectedMonitorID) {
                                ForEach(availableMonitors, id: \.id) { monitor in
                                    Text(monitor.name).tag(monitor.id as CGDirectDisplayID?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.bottom, 10)
                        }
                        // 👆 END NEW
            Button("⚡ AAA Default (1920×1200)") {
                applyHybridResolution(width: 1920, height: 1200)
            }
            .buttonStyle(.borderedProminent)

            Button("🎮 Smooth (1512×982)") {
                applyHybridResolution(width: 1512, height: 982)
            }
            .buttonStyle(.borderedProminent)

            Button("🎬 Cinematic (2048×1330)") {
                applyHybridResolution(width: 2048, height: 1330)
            }
            .buttonStyle(.borderedProminent)

            Button("🔋 Battery Saver (1024×665)") {
                applyHybridResolution(width: 1024, height: 665)
            }
            .buttonStyle(.borderedProminent)
            Button("🛠 Custom Resolution...") {
                showCustomResolution = true
            }
            .buttonStyle(.borderedProminent)

            Divider().padding(.vertical, 5)

            Button("🔄 Reset to macOS Default (1512×982)") {
                applyHybridResolution(width: 1512, height: 982)
            }
            .buttonStyle(.bordered)
            HStack {
                            Button("📄 Open Logs") {
                                AppLogger.shared.openLogFile()
                            }
                            .buttonStyle(.plain) // Makes it look like a link
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("🗑 Clear Logs") {
                                AppLogger.shared.clearLogs()
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red)
                        }
                        .padding(.top, 10)
                        .font(.caption)
        }
        .padding()
        .frame(width: 330, height: 450)
        .onAppear {
                    // 1. Load Screens
                    self.availableMonitors = ResolutionManager.shared.getAvailableScreens()
                    
                    // 2. Select the first one by default
                    if let first = availableMonitors.first {
                        self.selectedMonitorID = first.id
                    }
                    
                    // 3. Load Scaling Modes (Optional: You might want to skip this for now or update it later)
                     self.scalingModes = fetchScalingModes()
                }
        .sheet(isPresented: $showCustomResolution) {
            CustomResolutionView(onApply: { width, height in
                // Small delay ensures the sheet closes before the screen flashes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    applyHybridResolution(width: width, height: height)
                }
            })
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

    // Note the new argument: targetID
    func runDisplayPlacer(targetID: CGDirectDisplayID, width: Int, height: Int) {
            
            guard let bundledPath = bundledDisplayplacerPath() else {
                let err = "❌ Error: bundled displayplacer path not found"
                AppLogger.shared.log(err)
                alertMessage = err
                showAlert = true
                return
            }
            
            let resString = "\(width)x\(height)"
            
            // Define the Helper Command with Logging
            func executeCommand(scaling: Bool) -> Bool {
                let scalingFlag = scaling ? " scaling:on" : ""
                
                // 📝 Log exactly what command is running
                AppLogger.shared.log("👉 Executing displayplacer: id:\(targetID) res:\(resString)\(scalingFlag)")
                
                let process = Process()
                process.executableURL = URL(fileURLWithPath: bundledPath)
                
                // Passing the specific ID
                process.arguments = ["id:\(targetID) res:\(resString)\(scalingFlag)"]
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    if process.terminationStatus == 0 {
                        AppLogger.shared.log("✅ displayplacer Success")
                        return true
                    } else {
                        AppLogger.shared.log("⚠️ displayplacer Failed (Exit Code: \(process.terminationStatus))")
                        return false
                    }
                } catch {
                    AppLogger.shared.log("❌ displayplacer Crash: \(error.localizedDescription)")
                    return false
                }
            }

            // ATTEMPT 1: Try Normal
            if executeCommand(scaling: false) {
                alertMessage = "✅ Switched (Fallback)"
                showAlert = true
                return
            }
            
            // ATTEMPT 2: Try Scaling (if normal failed)
            AppLogger.shared.log("⚠️ Standard displayplacer failed. Retrying with Scaling...")
            if executeCommand(scaling: true) {
                alertMessage = "✅ Switched (Scaled Fallback)"
                showAlert = true
                return
            }
            
            // FINAL FAILURE
            let failMsg = "❌ Failed to set resolution via displayplacer."
            AppLogger.shared.log(failMsg)
            alertMessage = failMsg
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
    func applyHybridResolution(width: Int, height: Int) {
            // 👇 ADD THIS: Push the heavy work to the next render cycle
            DispatchQueue.main.async {
                
                // ... (All your existing logic goes here) ...
                
                guard let screenID = self.selectedMonitorID else { // Use 'self.' inside closures
                    AppLogger.shared.log("❌ Error: No monitor selected.")
                    self.alertMessage = "❌ No monitor selected."
                    self.showAlert = true
                    return
                }

                AppLogger.shared.log("👉 User requested \(width)x\(height) on Screen ID: \(screenID)")

                // 1. Try Exact
                let result = ResolutionManager.shared.setResolution(screenID: screenID, width: width, height: height)
                
                if result.success {
                    AppLogger.shared.log("✅ Success (Native): \(result.message)")
                    self.alertMessage = result.message
                    self.showAlert = true
                    return
                } else {
                    AppLogger.shared.log("⚠️ Native Exact Failed: \(result.message)")
                }
                
                // 2. Smart Retry Logic
                let ratio = Double(width) / Double(height)
                if abs(ratio - (16.0/9.0)) < 0.05 {
                    let newHeight = Int(Double(width) / 1.6)
                    AppLogger.shared.log("🔄 Attempting Smart Retry (16:10 fix): \(width)x\(newHeight)")
                    
                    let retryResult = ResolutionManager.shared.setResolution(screenID: screenID, width: width, height: newHeight)
                    if retryResult.success {
                        AppLogger.shared.log("✅ Success (Smart Retry): Switched to \(width)x\(newHeight)")
                        self.alertMessage = "✅ Auto-Corrected to \(width)x\(newHeight)"
                        self.showAlert = true
                        return
                    } else {
                        AppLogger.shared.log("❌ Smart Retry Failed: \(retryResult.message)")
                    }
                }

                // 3. Fallback
                AppLogger.shared.log("👉 Falling back to displayplacer...")
                self.runDisplayPlacer(targetID: screenID, width: width, height: height)
            }
        }
}
