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
        Table(configurations ?? [], selection: $selecteduuids) {
            // Synchronize ID column
            TableColumn("Synchronize ID") { data in
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
            .width(min: 100, ideal: 150, max: 200)
            
            // Action column
            TableColumn("Action") { data in
                if data.task == SharedReference.shared.halted {
                    Image(systemName: "stop.fill")
                        .foregroundColor(Color(.red))
                } else {
                    Text(data.task)
                }
            }
            .width(min: 60, ideal: 80, max: 100)
            
            // Source folder column
            TableColumn("Source folder") { data in
                Text(data.localCatalog)
                    .lineLimit(1)
            }
            .width(min: 80, ideal: 150, max: 250)
            
            // Server column
            TableColumn("Server") { data in
                if data.offsiteServer.count > 0 {
                    Text(data.offsiteServer)
                } else {
                    Text("localhost")
                }
            }
            .width(min: 50, ideal: 90, max: 150)
        }
    }
}
