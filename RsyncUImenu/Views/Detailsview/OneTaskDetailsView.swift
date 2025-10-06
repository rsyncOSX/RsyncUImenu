//
//  OneTaskDetailsView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 11/11/2023.
//

import Foundation
import Observation
import SwiftUI

struct OneTaskDetailsView: View {
    @Bindable var progressdetails: ProgressDetails
    @State private var estimateiscompleted = false
    @State private var remotedatanumbers: RemoteDataNumbers?

    let selecteduuids: Set<SynchronizeConfiguration.ID>
    let configurations: [SynchronizeConfiguration]

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if estimateiscompleted == true {
                    if let remotedatanumbers {
                        DetailsView(remotedatanumbers: remotedatanumbers)
                    }
                } else {
                    VStack {
                        // Only one task is estimated if selected, if more than one
                        // task is selected multiple estimation is selected. That is why
                        // that is why (uuid: selecteduuids.first)
                        if let config = getconfig(uuid: selecteduuids.first) {
                            Text("Estimating now: " + "\(config.backupID)")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }

                        ProgressView()
                    }
                }
            }
        }
        .onAppear(perform: {
            var selectedconfig: SynchronizeConfiguration?
            let selected = configurations.filter { config in
                selecteduuids.contains(config.id)
            }
            if selected.count == 1 {
                selectedconfig = selected[0]
            }
            let arguments = ArgumentsSynchronize(config: selectedconfig)
                .argumentssynchronize(dryRun: true, forDisplay: false)
            guard arguments != nil else { return }

            if SharedReference.shared.rsyncversion3 {
                let process = ProcessRsyncVer3x(arguments: arguments,
                                                config: selectedconfig,
                                                processtermination: processtermination)
                process.executeProcess()
            } else {
                let process = ProcessRsyncOpenrsync(arguments: arguments,
                                                    config: selectedconfig,
                                                    processtermination: processtermination)
                process.executeProcess()
            }
        })
    }

    private func getconfig(uuid: UUID?) -> SynchronizeConfiguration? {
        if let index = configurations.firstIndex(where: { $0.id == uuid }) {
            return configurations[index]
        }
        return nil
    }

    func validatetagging(_ lines: Int, _ tagged: Bool) throws {
        if lines > SharedReference.shared.alerttagginglines, tagged == false {
            throw ErrorDatatoSynchronize.thereisdatatosynchronize(idwitherror: "Current Synchronization ID")
        }
    }

    func processtermination(stringoutputfromrsync: [String]?, hiddenID _: Int?) {
        var selectedconfig: SynchronizeConfiguration?
        let selected = configurations.filter { config in
            selecteduuids.contains(config.id)
        }
        if selected.count == 1 {
            selectedconfig = selected[0]
        }

        if (stringoutputfromrsync?.count ?? 0) > 20, let stringoutputfromrsync {
            let suboutput = PrepareOutputFromRsync().prepareOutputFromRsync(stringoutputfromrsync)
            remotedatanumbers = RemoteDataNumbers(stringoutputfromrsync: suboutput,
                                                  config: selectedconfig)
        } else {
            remotedatanumbers = RemoteDataNumbers(stringoutputfromrsync: stringoutputfromrsync,
                                                  config: selectedconfig)
        }

        // Validate that tagging is correct
        do {
            try validatetagging(stringoutputfromrsync?.count ?? 0, remotedatanumbers?.datatosynchronize ?? true)
        } catch let e {
            let error = e
            SharedReference.shared.errorobject?.alert(error: error)
        }

        Task {
            remotedatanumbers?.outputfromrsync = await ActorCreateOutputforView().createaoutputforview(stringoutputfromrsync)

            if let remotedatanumbers {
                progressdetails.appendrecordestimatedlist(remotedatanumbers)
            }

            estimateiscompleted = true
        }
    }
}
