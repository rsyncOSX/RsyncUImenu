//
//  ExecuteNoEstTasksView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 11/11/2023.
//

import OSLog
import SwiftUI

struct ExecuteNoEstTasksView: View {
    @Bindable var rsyncUIdata: RsyncUIconfigurations
    @Binding var selecteduuids: Set<UUID>
    // Navigation path for executetasks
    @Binding var executetaskpath: [Tasks]

    @State private var noestprogressdetails = NoEstProgressDetails()
    @State private var progressviewshowinfo: Bool = true

    @State private var progress: Int = 0

    var body: some View {
        ZStack {
            ConfigurationsTableDataView(selecteduuids: $selecteduuids,
                                        configurations: rsyncUIdata.configurations)

            if progressviewshowinfo {
                VStack {
                    ProgressView()

                    Text("\(Int(progress))")
                        .font(.title2)
                        .contentTransition(.numericText(countsDown: false))
                        .animation(.default, value: progress)
                }
            }
        }
        .onAppear(perform: {
            executeallnoestimationtasks()
        })
        .onDisappear(perform: {
            if SharedReference.shared.process != nil {
                InterruptProcess()
            }
        })
        .toolbar(content: {
            ToolbarItem {
                Button {
                    abort()
                } label: {
                    Image(systemName: "stop.fill")
                }
                .help("Abort (⌘K)")
            }
        })
    }
}

extension ExecuteNoEstTasksView {
    func filehandler(count: Int) {
        progress = count
    }

    func abort() {
        selecteduuids.removeAll()
        InterruptProcess()
        progressviewshowinfo = false
        noestprogressdetails.reset()
    }

    func executeallnoestimationtasks() {
        Logger.process.info("executeallnoestimationtasks(): \(selecteduuids, privacy: .public)")
        noestprogressdetails.startexecutealltasksnoestimation()
        if let configurations = rsyncUIdata.configurations {
            EstimateExecute(profile: rsyncUIdata.profile,
                            configurations: configurations,
                            selecteduuids: selecteduuids,
                            noestprogressdetails: noestprogressdetails,
                            filehandler: filehandler,
                            updateconfigurations: updateconfigurations)
        }
    }

    func updateconfigurations(_ configurations: [SynchronizeConfiguration]) {
        Logger.process.info("Updateconfigurations() in memory\nReset data and return to MAIN THREAD task view")
        rsyncUIdata.configurations = configurations
        progressviewshowinfo = false
        noestprogressdetails.reset()
        executetaskpath.append(Tasks(task: .completedview))
    }
}
