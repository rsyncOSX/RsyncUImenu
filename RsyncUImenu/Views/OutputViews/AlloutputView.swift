//
//  AlloutputView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 12/11/2025.
//

import SwiftUI
import RsyncProcess

// Example second window view
struct AlloutputView: View {
    @Environment(\.dismiss) var dismiss
    @State private var output: [LogfileRecords] = []

    var body: some View {
        VStack {
            Table(output) {
                TableColumn("Ouput from Rsync") { data in
                    Text(data.line)
                }
            }

            if #available(macOS 26.0, *) {
                Button("Close", role: .close) {
                    dismiss()
                }
                .buttonStyle(RefinedGlassButtonStyle())

            } else {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .task {
            // Load lines asynchronously from the actor on appearance
            let allLines = await RsyncOutputCapture.shared.getAllLines()
            self.output = allLines.map({ line in
                LogfileRecords(line: line)
            })
        }
    }
}
