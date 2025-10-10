//
//  ConfigurationsTableDataMainView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 03/04/2024.
//

import SwiftUI

struct ConfigurationsTableDataMainView: View {
    @Environment(\.colorScheme) var colorScheme

    @Bindable var rsyncUIdata: RsyncUIconfigurations
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>
    @Binding var progress: Double

    let progressdetails: ProgressDetails
    let max: Double
    let synchronizatioofdatainprogress: Bool

    var body: some View {
        List(configurations, selection: $selecteduuids) { data in
            HStack(spacing: 12) {
                if synchronizatioofdatainprogress {
                    // Progress section
                    if data.hiddenID == progressdetails.hiddenIDatwork, max > 0, progress <= max {
                        HStack {
                            ProgressView("", value: progress, total: max)
                                .frame(width: 50)
                            Text("\(Int(max)) : \(Int(progress))")
                                .contentTransition(.numericText(countsDown: false))
                                .animation(.default, value: progress)
                        }
                        .frame(minWidth: 100, maxWidth: 150, alignment: .leading)
                    } else {
                        Spacer().frame(width: 150)
                    }
                }

                // Synchronize ID section
                VStack(alignment: .leading) {
                    if let index = progressdetails.estimatedlist?.firstIndex(where: { $0.id == data.id }) {
                        if progressdetails.estimatedlist?[index].datatosynchronize == false,
                           progressdetails.estimatedlist?[index].preparedoutputfromrsync?.count ?? 0 > SharedReference.shared.alerttagginglines
                        {
                            Text(data.backupID.isEmpty ? "Synchronize ID" : data.backupID)
                                .foregroundColor(.yellow)
                            Text(rsyncUIdata.profile ?? "Default")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        } else {
                            let color: Color = progressdetails.estimatedlist?[index].datatosynchronize == true ? .blue : .red
                            Text(data.backupID.isEmpty ? "Synchronize ID" : data.backupID)
                                .foregroundColor(color)
                        }
                    } else {
                        Text(data.backupID.isEmpty ? "Synchronize ID" : data.backupID)
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 150, alignment: .leading)

                // Action section
                Group {
                    if data.task == SharedReference.shared.halted {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                    } else {
                        Text(data.task)
                    }
                }
                .frame(width: 80)
                .contextMenu {
                    Button("Toggle halt task") {
                        let index = getindex(selecteduuids)
                        guard index != -1 else { return }
                        updatehalted(index)
                    }
                }

                // Source folder
                Text(data.localCatalog)
                    .frame(minWidth: 100, maxWidth: 200, alignment: .leading)
                    .lineLimit(1)

                // Server
                Text(data.offsiteServer.count > 0 ? data.offsiteServer : "localhost")
                    .frame(width: 90)

                // Time section
                let seconds: Double = {
                    if let date = data.dateRun {
                        let lastbackup = date.en_date_from_string()
                        return lastbackup.timeIntervalSinceNow * -1
                    }
                    return 0
                }()
                let color: Color = markconfig(seconds) == true ? .red : (colorScheme == .dark ? .white : .black)

                Text(seconds.latest())
                    .frame(width: 90, alignment: .trailing)
                    .foregroundColor(color)
            }
            .padding(.vertical, -4)
        }
    }

    var configurations: [SynchronizeConfiguration] {
        rsyncUIdata.configurations ?? []
    }

    private func markconfig(_ seconds: Double) -> Bool {
        seconds / (60 * 60 * 24) > Double(SharedReference.shared.marknumberofdayssince)
    }

    private func getindex(_: Set<UUID>) -> Int {
        if let configurations = rsyncUIdata.configurations {
            if let index = configurations.firstIndex(where: { $0.id == selecteduuids.first }) {
                index
            } else {
                -1
            }
        } else {
            -1
        }
    }

    private func updatehalted(_ index: Int) {
        if let halted = rsyncUIdata.configurations?[index].halted,
           let task = rsyncUIdata.configurations?[index].task
        {
            if halted == 0 {
                // Halt task
                switch task {
                case SharedReference.shared.synchronize:
                    rsyncUIdata.configurations?[index].halted = 1
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.halted
                case SharedReference.shared.syncremote:
                    rsyncUIdata.configurations?[index].halted = 2
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.halted
                case SharedReference.shared.snapshot:
                    rsyncUIdata.configurations?[index].halted = 3
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.halted
                default:
                    break
                }
            } else {
                // Enable task
                switch halted {
                case 1:
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.synchronize
                    rsyncUIdata.configurations?[index].halted = 0
                case 2:
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.syncremote
                    rsyncUIdata.configurations?[index].halted = 0
                case 3:
                    rsyncUIdata.configurations?[index].task = SharedReference.shared.snapshot
                    rsyncUIdata.configurations?[index].halted = 0
                default:
                    break
                }
            }
            WriteSynchronizeConfigurationJSON(rsyncUIdata.profile, rsyncUIdata.configurations)
            selecteduuids.removeAll()
        }
    }
}

/*
 enum Halted: Int {
     case synchronize = 1 // before halted synchronize
     case syncremote = 2 // as above but syncremote
     case snapshot = 3 // as above but
 }
 */
