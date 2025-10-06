//
//  WriteSynchronizeConfigurationJSON.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 27/04/2021.
//
// swiftlint:disable line_length

import DecodeEncodeGeneric
import Foundation
import OSLog

@MainActor
final class WriteSynchronizeConfigurationJSON {
    let path = Homepath()

    private func writeJSONToPersistentStore(jsonData: Data?, _ profile: String?) {
        if let fullpathmacserial = path.fullpathmacserial {
            var configurationfileURL: URL?
            let fullpathmacserialURL = URL(fileURLWithPath: fullpathmacserial)
            if let profile {
                let tempURL = fullpathmacserialURL.appendingPathComponent(profile)
                configurationfileURL = tempURL.appendingPathComponent(SharedConstants().fileconfigurationsjson)

            } else {
                configurationfileURL = fullpathmacserialURL.appendingPathComponent(SharedConstants().fileconfigurationsjson)
            }
            if let jsonData, let configurationfileURL {
                do {
                    try jsonData.write(to: configurationfileURL)
                    let myprofile = profile ?? "Default"
                    Logger.process.info("WriteSynchronizeConfigurationJSON - \(myprofile), privacy: .public): write configurations to permanent storage \(configurationfileURL.path(), privacy: .public)")
                } catch let e {
                    let error = e
                    path.propogateerror(error: error)
                }
            }
        }
    }

    private func encodeJSONData(_ configurations: [SynchronizeConfiguration], _ profile: String?) {
        let encodejsondata = EncodeGeneric()
        do {
            if let encodeddata = try encodejsondata.encodedata(data: configurations) {
                writeJSONToPersistentStore(jsonData: encodeddata, profile)
            }
        } catch let e {
            let error = e
            path.propogateerror(error: error)
        }
    }

    @discardableResult
    init(_ profile: String?, _ configurations: [SynchronizeConfiguration]?) {
        if let configurations {
            encodeJSONData(configurations, profile)
        }
    }

    deinit {
        Logger.process.info("WriteSynchronizeConfigurationJSON DEINIT")
    }
}

// swiftlint:enable line_length
