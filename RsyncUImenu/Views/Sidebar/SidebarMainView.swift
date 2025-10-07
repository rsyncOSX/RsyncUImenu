//
//  SidebarMainView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 12/12/2023.
//

import OSLog
import SwiftUI

struct SidebarMainView: View {
    @Bindable var rsyncUIdata: RsyncUIconfigurations
    // The selectedprofileID is updated by the profile picker
    // The selectedprofileID is monitored by the RsyncUImenuView and when changed
    // a new profile is loaded
    @Binding var selectedprofileID: ProfilesnamesRecord.ID?
    @Bindable var errorhandling: AlertError
    @Binding var executetaskpath: [Tasks]

    @State private var progressdetails = ProgressDetails()
    @State private var selecteduuids = Set<SynchronizeConfiguration.ID>()

    var body: some View {
        NavigationStack {
            SidebarTasksView(rsyncUIdata: rsyncUIdata,
                             progressdetails: progressdetails,
                             selecteduuids: $selecteduuids,
                             executetaskpath: $executetaskpath,
                             selectedprofileID: $selectedprofileID)
        }
        .alert(isPresented: errorhandling.presentalert, content: {
            if let error = errorhandling.activeError {
                Alert(localizedError: error)
            } else {
                Alert(title: Text("No error"))
            }
        })
        .onChange(of: selectedprofileID) {
            // Only clean selecteuuids, new profile is loaded
            // in RsyncUImenuView
            selecteduuids.removeAll()
        }
    }
}
