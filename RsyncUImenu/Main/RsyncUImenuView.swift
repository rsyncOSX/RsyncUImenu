//
//  RsyncUImenuView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 17/06/2021.
//

import OSLog
import RsyncProcess
import SwiftUI

struct RsyncUImenuView: View {
    @Binding var executetaskpath: [Tasks]
    // Selected profile
    @State private var selectedprofileID: ProfilesnamesRecord.ID?
    // Set version of rsync to use
    @State private var rsyncversion = Rsyncversion()
    @State private var rsyncUIdata = RsyncUIconfigurations()

    var body: some View {
        VStack {
            SidebarMainView(rsyncUIdata: rsyncUIdata,
                            selectedprofileID: $selectedprofileID,
                            errorhandling: errorhandling,
                            executetaskpath: $executetaskpath)
        }
        .task {
            guard rsyncUIdata.configurations == nil else { return }

            await RsyncOutputCapture.shared.enable()
            // Or with file output:
            // let logURL = FileManager.default.temporaryDirectory.appendingPathComponent("rsync-output.log")
            // await RsyncOutputCapture.shared.enable(writeToFile: logURL)

            Homepath().createrootprofilecatalog()
            ReadUserConfigurationJSON().readuserconfiguration()
            // Get version of rsync
            rsyncversion.getrsyncversion()
            rsyncUIdata.configurations = await ActorReadSynchronizeConfigurationJSON()
                .readjsonfilesynchronizeconfigurations(nil,
                                                       SharedReference.shared.rsyncversion3,
                                                       SharedReference.shared.monitornetworkconnection,
                                                       SharedReference.shared.sshport)

            // Load valid profilenames
            let catalognames = Homepath().getfullpathmacserialcatalogsasstringnames()
            rsyncUIdata.validprofiles = catalognames.map { catalog in
                ProfilesnamesRecord(catalog)
            }
        }
        .onChange(of: selectedprofileID) {
            var profile: String?

            if let index = rsyncUIdata.validprofiles.firstIndex(where: { $0.id == selectedprofileID }) {
                rsyncUIdata.profile = rsyncUIdata.validprofiles[index].profilename
                profile = rsyncUIdata.validprofiles[index].profilename
            } else {
                rsyncUIdata.profile = nil
                profile = nil
            }

            Task {
                rsyncUIdata.profile = profile

                rsyncUIdata.configurations = await ActorReadSynchronizeConfigurationJSON()
                    .readjsonfilesynchronizeconfigurations(profile,
                                                           SharedReference.shared.rsyncversion3,
                                                           SharedReference.shared.monitornetworkconnection,
                                                           SharedReference.shared.sshport)
            }
        }
    }

    var errorhandling: AlertError {
        SharedReference.shared.errorobject = AlertError()
        return SharedReference.shared.errorobject ?? AlertError()
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
