//
//  Rsyncversion.swift
//  RsyncSwiftUI
//
//  Created by Thomas Evensen on 18/01/2021.
//

import Foundation
import Observation
import OSLog

@Observable @MainActor
final class Rsyncversion {
    func getrsyncversion() {
        do {
            try SetandValidatepathforrsync().validatelocalpathforrsync()
        } catch {
            SharedReference.shared.norsync = true
            SharedReference.shared.rsyncversionshort = "No valid rsync deteced"
        }
        if SharedReference.shared.norsync == false {
            let command = ProcessRsyncVer3x(arguments: ["--version"],
                                            processtermination: processtermination)
            command.executeProcess()
        }
    }

    init() {
        let silicon = ProcessInfo().machineHardwareName?.contains("arm64") ?? false
        if silicon {
            SharedReference.shared.macosarm = true
        } else {
            SharedReference.shared.macosarm = false
        }
    }
}

extension Rsyncversion {
    func processtermination(stringoutputfromrsync: [String]?, hiddenID _: Int?) {
        guard stringoutputfromrsync?.count ?? 0 > 0 else { return }
        if let rsyncversionshort = stringoutputfromrsync?[0] {
            SharedReference.shared.rsyncversionshort =
                rsyncversionshort.replacingOccurrences(of: "protocol", with: "\nprotocol")

            if rsyncversionshort.contains("version 3.") {
                SharedReference.shared.rsyncversion3 = true
                Logger.process.info("Rsyncversion: version 3.x of rsync discovered")
            } else {
                SharedReference.shared.rsyncversion3 = false
                Logger.process.info("Rsyncversion: default openrsync discovered")
            }
        }
    }
}

extension ProcessInfo {
    /// Returns a `String` representing the machine hardware name or nil if there was an error invoking `uname(_:)`
    ///  or decoding the response. Return value is the equivalent to running `$ uname -m` in shell.
    var machineHardwareName: String? {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        guard result == EXIT_SUCCESS else { return nil }
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
}
