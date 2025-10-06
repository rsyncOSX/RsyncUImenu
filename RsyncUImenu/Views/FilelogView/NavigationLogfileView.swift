//
//  NavigationLogfileView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 25/11/2023.
//

import Foundation
import Observation
import SwiftUI

struct NavigationLogfileView: View {
    @State private var resetloggfile = false
    @State private var logfilerecords: [LogfileRecords]?

    var body: some View {
        VStack {
            Table(logfilerecords ?? []) {
                TableColumn("Logfile") { data in
                    Text(data.line)
                }
            }
            .onChange(of: resetloggfile) {
                afterareload()
            }
        }
        .padding()
        .onAppear {
            Task {
                logfilerecords = await ActorCreateOutputforView().createaoutputlogfileforview()
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    reset()
                } label: {
                    Image(systemName: "clear")
                }
                .help("Reset logfile")
            }
        }
    }

    func reset() {
        resetloggfile = true

        Task {
            await ActorLogToFile(true)
            logfilerecords = await ActorCreateOutputforView().createaoutputlogfileforview()
        }
    }

    func afterareload() {
        resetloggfile = false
    }
}

struct LogfileRecords: Identifiable {
    let id = UUID()
    var line: String
}

@Observable @MainActor
final class Logfileview {
    var output: [LogfileRecords]?
}
