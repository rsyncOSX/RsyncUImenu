//
//  ListofTasksMainView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 11/11/2023.
//

import SwiftUI

struct ListofTasksMainView: View {
    @Bindable var rsyncUIdata: RsyncUIconfigurations
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>
    @Binding var doubleclick: Bool
    // Progress of synchronization
    @Binding var progress: Double

    @State private var confirmdelete: Bool = false

    let progressdetails: ProgressDetails
    let max: Double

    var body: some View {
        ConfigurationsTableDataMainView(rsyncUIdata: rsyncUIdata,
                                        selecteduuids: $selecteduuids,
                                        progress: $progress,
                                        progressdetails: progressdetails,
                                        max: max,
                                        synchronizatioofdatainprogress: max > 0)
            .overlay {
                if (rsyncUIdata.configurations ?? []).isEmpty {
                    ContentUnavailableView {
                        Label("There are no tasks", systemImage: "doc.richtext.fill")
                    } description: {
                        Text("Use RsyncUI to add tasks")
                    }
                }
            }
            .confirmationDialog(selecteduuids.count == 1 ? "Delete 1 configuration" :
                "Delete \(selecteduuids.count) configurations",
                isPresented: $confirmdelete)
            {
                Button("Delete") {
                    delete()
                    confirmdelete = false
                }
            }
            .contextMenu(forSelectionType: SynchronizeConfiguration.ID.self) { _ in
            } primaryAction: { _ in
                // Only allow double click if one task is selected
                guard selecteduuids.count == 1 else { return }
                doubleclick = true
            }
            .onDeleteCommand {
                confirmdelete = true
            }
    }

    func delete() {
        if let configurations = rsyncUIdata.configurations {
            let deleteconfigurations =
                UpdateConfigurations(profile: rsyncUIdata.profile,
                                     configurations: configurations)
            deleteconfigurations.deleteconfigurations(selecteduuids)
            selecteduuids.removeAll()
            rsyncUIdata.configurations = deleteconfigurations.configurations
        }
    }
}
