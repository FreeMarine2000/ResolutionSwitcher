import SwiftUI
import AppKit

@main
struct ResolutionSwitcherApp: App {
    // connect the delegate
    @NSApplicationDelegateAdaptor(ResolutionAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 330, height: 450) // Set the window size here
                .onAppear {
                    // Optional: Lock the window size so it can't be resized
                    if let window = NSApplication.shared.windows.first {
                        window.styleMask.remove(.resizable)
                    }
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar) // Makes it look like a clean utility
    }
}

// Custom Delegate for Menu Bar & Dock Logic
class ResolutionAppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the Menu Bar (Fixes Command+Q)
        setupMenu()
        
        // 2. Bring app to front
        NSApp.activate(ignoringOtherApps: true)
    }

    // Forces App to Quit when Red X is clicked
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func setupMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu
        
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        // Add "About"
        appMenu.addItem(withTitle: "About Resolution Switcher", action: nil, keyEquivalent: "")
        
        appMenu.addItem(NSMenuItem.separator())
        
        // Add "Quit" (Mapped to Command + Q)
        appMenu.addItem(withTitle: "Quit Resolution Switcher", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }
}
