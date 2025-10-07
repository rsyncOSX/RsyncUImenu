//
//  DetailsViewHeading.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 20/11/2024.
//

import SwiftUI

struct DetailsViewHeading: View {
    let remotedatanumbers: RemoteDataNumbers

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    LabeledContent("Synchronize ID: ") {
                        if remotedatanumbers.backupID.count == 0 {
                            Text("Synchronize ID")
                                .foregroundColor(.blue)
                        } else {
                            Text(remotedatanumbers.backupID)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(-3)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 200, alignment: .leading)

                    LabeledContent("Task: ") {
                        Text(remotedatanumbers.task)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Source folder: ") {
                        Text(remotedatanumbers.localCatalog)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Destination folder: ") {
                        Text(remotedatanumbers.offsiteCatalog)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Server: ") {
                        if remotedatanumbers.offsiteServer.count == 0 {
                            Text("localhost")
                                .foregroundColor(.blue)
                        } else {
                            Text(remotedatanumbers.offsiteServer)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(-3)
                }
                .padding()

                VStack(alignment: .leading) {
                    LabeledContent("Total number of files: ") {
                        Text(remotedatanumbers.numberoffiles)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Total number of catalogs: ") {
                        Text(remotedatanumbers.totaldirectories)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Total numbers: ") {
                        Text(remotedatanumbers.totalnumbers)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)

                    LabeledContent("Total bytes: ") {
                        Text(remotedatanumbers.totalfilesize)
                            .foregroundColor(.blue)
                    }
                    .padding(-3)
                }
                .padding()
            }
        }
    }
}
