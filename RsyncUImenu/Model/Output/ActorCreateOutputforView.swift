//
//  ActorCreateOutputforView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 02/07/2025.
//

import OSLog

actor ActorCreateOutputforView {
    // From Array[String]
    @concurrent
    nonisolated func createaoutputforview(_ stringoutputfromrsync: [String]?) async -> [RsyncOutputData] {
        Logger.process.info("ActorCreateOutputforView: createaoutputforview() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
        if let stringoutputfromrsync {
            return stringoutputfromrsync.map { line in
                RsyncOutputData(record: line)
            }
        }
        return []
    }

    // From Set<String>
    @concurrent
    nonisolated func createaoutputforview(_ setoutputfromrsync: Set<String>?) async -> [RsyncOutputData] {
        Logger.process.info("ActorCreateOutputforView: createaoutputforview() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
        if let setoutputfromrsync {
            return setoutputfromrsync.map { line in
                RsyncOutputData(record: line)
            }
        }
        return []
    }

    // Logfile
    @concurrent
    nonisolated func createaoutputlogfileforview() async -> [LogfileRecords] {
        Logger.process.info("ActorCreateOutputforView: createaoutputlogfileforview() generatedata() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
        if let data = await ActorLogToFile(false).readloggfile() {
            return data.map { record in
                LogfileRecords(line: record)
            }
        } else {
            return []
        }
    }
}
