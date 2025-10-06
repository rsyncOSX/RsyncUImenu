//
//  SharedReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Observation

public extension Thread {
    static var isMain: Bool { isMainThread }
    static var currentThread: Thread { Thread.current }
}

@Observable
final class SharedReference {
    @MainActor static let shared = SharedReference()

    private init() {}

    // Version 3.x of rsync
    @ObservationIgnored var rsyncversion3: Bool = false
    // Optional path to rsync
    @ObservationIgnored var localrsyncpath: String?
    // No valid rsyncPath - true if no valid rsync is found
    @ObservationIgnored var norsync: Bool = false
    // Path for restore
    @ObservationIgnored var pathforrestore: String?
    // Add summary to logrecords
    @ObservationIgnored var addsummarylogrecord: Bool = true
    // Mark number of days since last backup
    @ObservationIgnored var marknumberofdayssince: Int = 5
    @ObservationIgnored var environment: String?
    @ObservationIgnored var environmentvalue: String?
    // Global SSH parameters
    @ObservationIgnored var sshport: Int?
    @ObservationIgnored var sshkeypathandidentityfile: String?
    // Check for error in output from rsync
    @ObservationIgnored var checkforerrorinrsyncoutput: Bool = false
    // Check for network changes
    @ObservationIgnored var monitornetworkconnection: Bool = false
    // Confirm execution
    // A safety rule
    @ObservationIgnored var confirmexecute: Bool = false
    // Synchronize without timedelay URL-actions
    @ObservationIgnored var synchronizewithouttimedelay: Bool = false
    // rsync command
    let rsync: String = "rsync"
    let usrbin: String = "/usr/bin"
    let usrlocalbin: String = "/usr/local/bin"
    let usrlocalbinarm: String = "/opt/homebrew/bin"
    @ObservationIgnored var macosarm: Bool = false
    // RsyncUImenu config files and path
    let configpath: String = "/.rsyncosx/"
    // Userconfiguration json file
    let userconfigjson: String = "rsyncuiconfig.json"
    // String tasks
    let synchronize: String = "synchronize"
    let snapshot: String = "snapshot"
    let syncremote: String = "syncremote"
    let halted: String = "halted"
    // rsync short version
    var rsyncversionshort: String?
    // Mac serialnumer
    @ObservationIgnored var macserialnumber: String?
    // Reference to the active process
    var process: Process?
    // Object for propogate errors to views
    @ObservationIgnored var errorobject: AlertError?
    // let bundleIdentifier: String = "no.blogspot.RsyncUImenu"
    @ObservationIgnored var sidebarishidden: Bool = false
    @ObservationIgnored var observemountedvolumes: Bool = false
    @ObservationIgnored var alwaysshowestimateddetailsview: Bool = true
    // Value for alert tagging
    let alerttagginglines = 20
    // Hide Verify Remote function in main Sidebar
    @ObservationIgnored var hideverifyremotefunction: Bool = true
    // Hide Calendar function in main Sidebar
    @ObservationIgnored var hideschedule: Bool = true
}
