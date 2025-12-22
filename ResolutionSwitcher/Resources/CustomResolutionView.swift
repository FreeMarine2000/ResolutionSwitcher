//
//  CustomResolutionView.swift
//  ResolutionSwitcher
//
//  Created by Anshul Shah  on 22/12/25.
//


import SwiftUI

struct CustomResolutionView: View {
    @Environment(\.dismiss) var dismiss
    
    // Inputs
    @State private var width: String = ""
    @State private var height: String = ""
    
    // Callback: Sends the numbers back to the main app
    var onApply: (Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🔧 Custom Resolution")
                .font(.headline)
            
            HStack {
                TextField("Width", text: $width)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                Text("x")
                
                TextField("Height", text: $height)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            .padding()
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Apply") {
                    // Convert text to Int safely
                    if let w = Int(width), let h = Int(height) {
                        onApply(w, h)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(width.isEmpty || height.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
