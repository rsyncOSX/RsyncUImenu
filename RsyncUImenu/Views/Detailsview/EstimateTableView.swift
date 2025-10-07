//
//  EstimateTableView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 01/11/2024.
//

import SwiftUI

struct EstimateTableView: View {
    @Environment(\.colorScheme) var colorScheme

    @Bindable var progressdetails: ProgressDetails
    let estimatinguuid: SynchronizeConfiguration.ID
    let configurations: [SynchronizeConfiguration]

    var body: some View {
        List(configurations) { data in
            HStack {
                // Synchronize ID column
                VStack(alignment: .leading) {
                    if data.id == estimatinguuid {
                        HStack {
                            Image(systemName: "arrowshape.right.fill")
                                .foregroundColor(Color(.blue))

                            if data.backupID.isEmpty {
                                Text("Synchronize ID")
                                    .foregroundColor(color(uuid: data.id))
                            } else {
                                Text(data.backupID)
                                    .foregroundColor(color(uuid: data.id))
                            }
                        }
                    } else {
                        if data.backupID.isEmpty {
                            Text("Synchronize ID")
                                .foregroundColor(color(uuid: data.id))
                        } else {
                            Text(data.backupID)
                                .foregroundColor(color(uuid: data.id))
                        }
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 200, alignment: .leading)

                Spacer()

                // Action column
                VStack {
                    if data.task == SharedReference.shared.halted {
                        Image(systemName: "stop.fill")
                            .foregroundColor(Color(.red))
                    } else {
                        Text(data.task)
                    }
                }
                .frame(maxWidth: 80)

                Spacer()

                // Source folder column
                Text(data.localCatalog)
                    .frame(minWidth: 80, maxWidth: 200, alignment: .leading)

                Spacer()

                // Server column
                VStack {
                    if data.offsiteServer.count > 0 {
                        Text(data.offsiteServer)
                    } else {
                        Text("localhost")
                    }
                }
                .frame(minWidth: 50, maxWidth: 90)
            }
        }
        .padding(.vertical, -4)
    }

    func color(uuid: UUID) -> Color {
        let filter = progressdetails.estimatedlist?.filter {
            $0.id == uuid
        }
        return filter?.isEmpty == false ? .blue : (colorScheme == .dark ? .white : .black)
    }
}
