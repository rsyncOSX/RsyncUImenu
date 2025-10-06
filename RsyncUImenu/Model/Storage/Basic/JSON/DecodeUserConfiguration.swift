//
//  DecodeUserConfiguration.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 12/02/2022.
//

import Foundation

struct DecodeUserConfiguration: Codable {
    let rsyncversion3: Int?
    // Detailed logging
    let addsummarylogrecord: Int?
    // Monitor network connection
    let monitornetworkconnection: Int?
    // local path for rsync
    let localrsyncpath: String?
    // temporary path for restore
    let pathforrestore: String?
    // days for mark days since last synchronize
    let marknumberofdayssince: String?
    // Global ssh keypath and port
    let sshkeypathandidentityfile: String?
    let sshport: Int?
    // Environment variable
    let environment: String?
    let environmentvalue: String?
    let checkforerrorinrsyncoutput: Int?
    // Confirm execute
    let confirmexecute: Int?
    // No timedaly synchronize URL actions
    let synchronizewithouttimedelay: Int?
    // Hide or show the Sidebar on startup
    let sidebarishidden: Int?
    // Observe mounting local atteched discs
    let observemountedvolumes: Int?
    // Alwasy show the summarized estimate view
    let alwaysshowestimateddetailsview: Int?
    // Hide Verify function
    let hideverifyremotefunction: Int?
    // Hide Calendar
    let hideschedule: Int?

    enum CodingKeys: String, CodingKey {
        case rsyncversion3
        case addsummarylogrecord
        case monitornetworkconnection
        case localrsyncpath
        case pathforrestore
        case marknumberofdayssince
        case sshkeypathandidentityfile
        case sshport
        case environment
        case environmentvalue
        case checkforerrorinrsyncoutput
        case confirmexecute
        case synchronizewithouttimedelay
        case sidebarishidden
        case observemountedvolumes
        case alwaysshowestimateddetailsview
        case hideverifyremotefunction
        case hideschedule
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rsyncversion3 = try values.decodeIfPresent(Int.self, forKey: .rsyncversion3)
        addsummarylogrecord = try values.decodeIfPresent(Int.self, forKey: .addsummarylogrecord)
        monitornetworkconnection = try values.decodeIfPresent(Int.self, forKey: .monitornetworkconnection)
        localrsyncpath = try values.decodeIfPresent(String.self, forKey: .localrsyncpath)
        pathforrestore = try values.decodeIfPresent(String.self, forKey: .pathforrestore)
        marknumberofdayssince = try values.decodeIfPresent(String.self, forKey: .marknumberofdayssince)
        sshkeypathandidentityfile = try values.decodeIfPresent(String.self, forKey: .sshkeypathandidentityfile)
        sshport = try values.decodeIfPresent(Int.self, forKey: .sshport)
        environment = try values.decodeIfPresent(String.self, forKey: .environment)
        environmentvalue = try values.decodeIfPresent(String.self, forKey: .environmentvalue)
        checkforerrorinrsyncoutput = try values.decodeIfPresent(Int.self, forKey: .checkforerrorinrsyncoutput)
        confirmexecute = try values.decodeIfPresent(Int.self, forKey: .confirmexecute)
        synchronizewithouttimedelay = try values.decodeIfPresent(Int.self, forKey: .synchronizewithouttimedelay)
        sidebarishidden = try values.decodeIfPresent(Int.self, forKey: .sidebarishidden)
        observemountedvolumes = try values.decodeIfPresent(Int.self, forKey: .observemountedvolumes)
        alwaysshowestimateddetailsview = try values.decodeIfPresent(Int.self, forKey: .alwaysshowestimateddetailsview)
        hideverifyremotefunction = try values.decodeIfPresent(Int.self, forKey: .hideverifyremotefunction)
        hideschedule = try values.decodeIfPresent(Int.self, forKey: .hideschedule)
    }
}
