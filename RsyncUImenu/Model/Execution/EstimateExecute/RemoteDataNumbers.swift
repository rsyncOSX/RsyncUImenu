//
//  RemoteDataNumbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import ParseRsyncOutput

@MainActor
struct RemoteDataNumbers: Identifiable, Hashable {
    var id: SynchronizeConfiguration.ID
    var hiddenID: Int = -1
    var filestransferred: String = ""
    var filestransferred_Int: Int = 0
    var totaltransferredfilessize_Int: Int = 0
    var numberoffiles: String = ""
    var totalfilesize: String = ""
    var totalfilesize_Int: Int = 0
    var totaldirectories: String = ""
    var totaldirectories_Int: Int = 0
    var newfiles: String = ""
    var newfiles_Int: Int = 0
    var deletefiles: String = ""
    var deletefiles_Int: Int = 0

    var totalnumbers: String = ""

    var task: String = ""
    var localCatalog: String = ""
    var offsiteCatalog: String = ""
    var offsiteServer: String = ""
    var backupID: String = ""

    // Detailed output used in Views, allocated as part of process termination estimate
    var outputfromrsync: [RsyncOutputData]?
    // True if data to synchronize
    var datatosynchronize: Bool = false
    // Ask if synchronizing so much data
    // is true or not. If not either yes,
    // new task or no if like server is not
    // online.
    var confirmexecute: Bool = false
    // Summarized stats
    var stats: String?
    // A reduced number of output
    var preparedoutputfromrsync: [String]?

    init(stringoutputfromrsync: [String]?,
         config: SynchronizeConfiguration?)
    {
        hiddenID = config?.hiddenID ?? -1
        task = config?.task ?? ""
        localCatalog = config?.localCatalog ?? ""
        offsiteServer = config?.offsiteServer ?? "localhost"
        offsiteCatalog = config?.offsiteCatalog ?? ""
        backupID = config?.backupID ?? "Synchronize ID"
        id = config?.id ?? UUID()

        // Prepareoutput prepares output from rsync for extracting the numbers only.
        // It removes all lines except the last 20 lines where summarized numbers are put
        // Normally this is done before calling the RemoteDataNumbers

        if stringoutputfromrsync?.count ?? 0 > 20 {
            preparedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(stringoutputfromrsync)
        } else {
            preparedoutputfromrsync = stringoutputfromrsync
        }
        if let preparedoutputfromrsync, preparedoutputfromrsync.count > 0 {
            let parsersyncoutput = ParseRsyncOutput(preparedoutputfromrsync,
                                                    SharedReference.shared.rsyncversion3)
            stats = parsersyncoutput.stats
            filestransferred = parsersyncoutput.formatted_filestransferred

            filestransferred_Int = parsersyncoutput.numbersonly?.filestransferred ?? 0
            totaldirectories_Int = parsersyncoutput.numbersonly?.totaldirectories ?? 0
            newfiles_Int = parsersyncoutput.numbersonly?.numberofcreatedfiles ?? 0
            deletefiles_Int = parsersyncoutput.numbersonly?.numberofdeletedfiles ?? 0

            totaltransferredfilessize_Int = Int(parsersyncoutput.numbersonly?.totaltransferredfilessize ?? 0)
            totalfilesize_Int = Int(parsersyncoutput.numbersonly?.totalfilesize ?? 0)

            numberoffiles = parsersyncoutput.formatted_numberoffiles
            totalfilesize = parsersyncoutput.formatted_totalfilesize
            totaldirectories = parsersyncoutput.formatted_totaldirectories
            newfiles = parsersyncoutput.formatted_numberofcreatedfiles

            deletefiles = parsersyncoutput.formatted_numberofdeletedfiles
            totalnumbers = parsersyncoutput.formatted_numberoffiles_totaldirectories

            datatosynchronize = parsersyncoutput.numbersonly?.datatosynchronize ?? true

            if SharedReference.shared.rsyncversion3,
               filestransferred_Int + totaldirectories_Int == newfiles_Int,
               datatosynchronize
            {
                confirmexecute = true
            }
        }
    }
}

// swiftlint:enable line_length
