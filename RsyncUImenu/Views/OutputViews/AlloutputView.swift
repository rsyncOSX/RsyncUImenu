//
//  AlloutputView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 12/11/2025.
//

import SwiftUI
import RsyncProcess
import Observation

struct AlloutputView: View {
    // The generated observable model from @Observable should be usable as an observable object here.
    // Using @ObservedObject to reference the shared singleton.
    @State private var model = PrintLines.shared

    var body: some View {
        NavigationView {
            List(model.output, id: \.self) { line in
                Text(line)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1)
                    .frame(minWidth: .infinity)
            }
            .navigationTitle("Rsync Output")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear") {
                        Task { @MainActor in
                            // model.clear()
                        }
                    }
                }
            }
        }
    }
}
