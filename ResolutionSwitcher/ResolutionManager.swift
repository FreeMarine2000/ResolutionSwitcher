import AppKit
import CoreGraphics

// Simple struct to hold screen info
struct MonitorInfo: Identifiable, Hashable {
    let id: CGDirectDisplayID
    let name: String
    
    // Conforming to Identifiable for SwiftUI Loops
    var idString: String { "\(id)" }
}

class ResolutionManager {
    static let shared = ResolutionManager()
    private init() {}

    /// Returns a list of all connected monitors
    func getAvailableScreens() -> [MonitorInfo] {
        var monitors: [MonitorInfo] = []
        
        for screen in NSScreen.screens {
            // Get the ID
            let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
            
            // Get a human-readable name
            let name = screen.localizedName
            
            monitors.append(MonitorInfo(id: id, name: name))
        }
        return monitors
    }

    /// Sets resolution for a SPECIFIC screen ID
    func setResolution(screenID: CGDirectDisplayID, width: Int, height: Int) -> (success: Bool, message: String) {
        
        // Fetch modes for this specific ID
        guard let modes = CGDisplayCopyAllDisplayModes(screenID, nil) as? [CGDisplayMode] else {
            return (false, "❌ No modes found for screen \(screenID)")
        }

        // Find match
        if let mode = modes.first(where: { $0.width == width && $0.height == height }) {
            
            var configRef: CGDisplayConfigRef?
            CGBeginDisplayConfiguration(&configRef)
            CGConfigureDisplayWithDisplayMode(configRef, screenID, mode, nil)
            let error = CGCompleteDisplayConfiguration(configRef, .forSession)
            
            if error == .success {
                return (true, "✅ Native: Switched to \(width)x\(height)")
            } else {
                return (false, "❌ Native: Commit failed")
            }
        } else {
            return (false, "⚠️ Mode \(width)x\(height) not found natively")
        }
    }
}
