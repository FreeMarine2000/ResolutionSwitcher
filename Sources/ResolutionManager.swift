import AppKit
import CoreGraphics
func setResolution(width: Int, height: Int) {
    guard let screen = NSScreen.main else {
        print("No screen found")
        return
    }

    let displayID =
        screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID

    guard let modes = CGDisplayCopyAllDisplayModes(displayID, nil) as? [CGDisplayMode] else {
        print("No display modes found")
        return
    }

    if let mode = modes.first(where: { $0.width == width && $0.height == height }) {
        var configRef: CGDisplayConfigRef?
        CGBeginDisplayConfiguration(&configRef)
        CGConfigureDisplayWithDisplayMode(configRef, displayID, mode, nil)
        CGCompleteDisplayConfiguration(configRef, .forSession)
        print("✅ Changed resolution to \(width)x\(height)")
    } else {
        print("❌ Resolution \(width)x\(height) not supported")
    }
}
