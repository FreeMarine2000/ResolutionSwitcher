//
//  AppLogger.swift
//  ResolutionSwitcher
//
//  Created by Anshul Shah  on 22/12/25.
//

import Foundation
import AppKit  // 👈 THIS WAS MISSING!

class AppLogger {
    static let shared = AppLogger()
    
    private let logFileURL: URL
    
    private init() {
        // Save logs in the User's "Documents" folder inside the App Sandbox
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        logFileURL = paths[0].appendingPathComponent("ResolutionSwitcher_Debug.txt")
        
        // Log the start of a new session
        log("=========== APP STARTED ===========")
        print("📂 Log File Path: \(logFileURL.path)")
    }
    
    /// Writes a message to the log file with a timestamp
    func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        
        let logEntry = "[\(timestamp)] \(message)\n"
        
        // 1. Print to Xcode Console (for you)
        print(logEntry, terminator: "")
        
        // 2. Append to Text File (for the user/debug)
        appendToFile(text: logEntry)
    }
    
    private func appendToFile(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: logFileURL, options: .atomic)
        }
    }
    
    /// Opens the log file in the default text editor (TextEdit)
    func openLogFile() {
        NSWorkspace.shared.open(logFileURL)
    }
    
    /// Clears the log file
    func clearLogs() {
        try? FileManager.default.removeItem(at: logFileURL)
        log("Logs cleared by user.")
    }
}
