//
//  ConfigurationsTableDataView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 03/04/2024.
//

import SwiftUI

struct ConfigurationsTableDataView: View {
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>

    let configurations: [SynchronizeConfiguration]?

    var body: some View {
        List(configurations ?? [], id: \.id, selection: $selecteduuids) { data in
            HStack(spacing: 12) {
                // Synchronize ID column
                VStack(alignment: .leading, spacing: 2) {
                    Text("Synchronize ID")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if data.parameter4.isEmpty == false {
                        if data.backupID.isEmpty == true {
                            Text("Synchronize ID")
                                .foregroundColor(.red)
                        } else {
                            Text(data.backupID)
                                .foregroundColor(.red)
                        }
                    } else {
                        if data.backupID.isEmpty == true {
                            Text("Synchronize ID")
                        } else {
                            Text(data.backupID)
                        }
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 150, alignment: .leading)

                // Action column
                VStack(alignment: .leading, spacing: 2) {
                    Text("Action")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if data.task == SharedReference.shared.halted {
                        Image(systemName: "stop.fill")
                            .foregroundColor(Color(.red))
                    } else {
                        Text(data.task)
                    }
                }
                .frame(maxWidth: 80, alignment: .leading)

                // Source folder column
                VStack(alignment: .leading, spacing: 2) {
                    Text("Source folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(data.localCatalog)
                        .lineLimit(1)
                }
                .frame(minWidth: 80, maxWidth: 200, alignment: .leading)

                // Server column
                VStack(alignment: .leading, spacing: 2) {
                    Text("Server")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if data.offsiteServer.count > 0 {
                        Text(data.offsiteServer)
                    } else {
                        Text("localhost")
                    }
                }
                .frame(minWidth: 50, maxWidth: 90, alignment: .leading)
            }
            .padding(.vertical, -4)
        }
    }
}
