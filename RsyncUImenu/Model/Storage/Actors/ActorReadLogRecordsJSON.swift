//
//  ActorReadLogRecordsJSON.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 04/12/2024.
//

import DecodeEncodeGeneric
import Foundation
import OSLog

actor ActorReadLogRecordsJSON {
    @concurrent
    nonisolated func readjsonfilelogrecords(_ profile: String?,
                                            _ validhiddenIDs: Set<Int>) async -> [LogRecords]?
    {
        let path = await Homepath()
        var filename = ""

        Logger.process.info("ActorReadLogRecordsJSON: readjsonfilelogrecords() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")

        if let profile, let fullpathmacserial = path.fullpathmacserial {
            filename = fullpathmacserial.appending("/") + profile.appending("/") + SharedConstants().filenamelogrecordsjson
        } else {
            if let fullpathmacserial = path.fullpathmacserial {
                filename = fullpathmacserial.appending("/") + SharedConstants().filenamelogrecordsjson
            }
        }

        Logger.process.info("ActorReadLogRecordsJSON: readjsonfilelogrecords() from \(filename, privacy: .public)")

        let decodeimport = DecodeGeneric()
        do {
            if let data = try
                decodeimport.decodearraydatafileURL(DecodeLogRecords.self, fromwhere: filename)
            {
                Logger.process.info("ActorReadLogRecordsJSON - \(profile ?? "default profile", privacy: .public): DECODE MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
                return data.compactMap { element in
                    let item = LogRecords(element)
                    return validhiddenIDs.contains(item.hiddenID) ? item : nil
                }
            }

        } catch let e {
            Logger.process.error("ActorReadLogRecordsJSON - \(profile ?? "default profile", privacy: .public): some ERROR reading logrecords from permanent storage")
            let error = e
            await path.propogateerror(error: error)
        }
        return nil
    }

    @concurrent
    nonisolated func updatelogsbyhiddenID(_ logrecords: [LogRecords]?, _ hiddenID: Int) async -> [Log]? {
        Logger.process.info("ActorReadLogRecordsJSON: updatelogsbyhiddenID() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
        if let logrecords {
            // hiddenID == -1, merge logrecords for all tasks.
            // if validhiddenID, merge logrecords for a specific task
            if hiddenID == -1 {
                var merged = [Log]()
                _ = logrecords.map { logrecord in
                    if let logrecords = logrecord.logrecords {
                        merged += [logrecords].flatMap(\.self)
                    }
                }
                // return merged.sorted(by: \.date, using: >)
                return merged.sorted(using: [KeyPathComparator(\Log.date, order: .reverse)])
            } else {
                if let index = logrecords.firstIndex(where: { $0.hiddenID == hiddenID }),
                   let logrecords = logrecords[index].logrecords
                {
                    return logrecords.sorted(using: [KeyPathComparator(\Log.date, order: .reverse)])
                }
            }
        }
        return nil
    }

    @concurrent
    nonisolated func updatelogsbyfilter(_ logrecords: [LogRecords]?, _ filterstring: String, _ hiddenID: Int) async -> [Log]? {
        Logger.process.info("ActorReadLogRecordsJSON: updatelogsbyfilter() MAIN THREAD: \(Thread.isMain) but on \(Thread.current)")
        guard filterstring != "" else { return nil }
        if let logrecords {
            if hiddenID == -1 {
                var merged = [Log]()
                _ = logrecords.map { logrecord in
                    if let logrecords = logrecord.logrecords {
                        merged += [logrecords].flatMap(\.self)
                    }
                }
                let records = merged.sorted(using: [KeyPathComparator(\Log.date, order: .reverse)])
                return records.filter { ($0.dateExecuted?.en_date_from_string().long_localized_string_from_date().contains(filterstring)) ?? false || ($0.resultExecuted?.contains(filterstring) ?? false)
                }
            } else {
                if let index = logrecords.firstIndex(where: { $0.hiddenID == hiddenID }),
                   let logrecords = logrecords[index].logrecords
                {
                    let records = logrecords.sorted(using: [KeyPathComparator(\Log.date, order: .reverse)])
                    return records.filter { ($0.dateExecuted?.en_date_from_string().long_localized_string_from_date().contains(filterstring)) ?? false || ($0.resultExecuted?.contains(filterstring) ?? false)
                    }
                }
            }
        }
        return nil
    }

    deinit {
        Logger.process.info("ActorReadLogRecordsJSON: DEINIT")
    }
}
