//
//  AboutView.swift
//  RsyncSwiftUI
//
//  Created by Thomas Evensen on 28/01/2021.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var changelog: String {
        Resources().getResource(resource: .changelog)
    }

    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }

    var appBuild: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1.0"
    }

    var copyright: String {
        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
        return copyright ?? NSLocalizedString("Copyright ©2025 Thomas Evensen", comment: "")
    }

    var configpath: String {
        Homepath().fullpathmacserial ?? ""
    }

    var body: some View {
        Form {
            Section(header: Text("RsyncUI menu app")
                .font(.title3)
                .fontWeight(.bold))
            {
                appnamestring

                copyrightstring

                HStack {
                    VStack(alignment: .leading) {
                        Image(nsImage: NSImage(named: NSImage.applicationIconName)!)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: 64, height: 64)
                    }

                    rsyncversionshortstring
                }

                rsyncuiconfigpathpath
            }

            Section {
                HStack {
                    Button {
                        openchangelog()
                        dismiss()
                    } label: {
                        Image(systemName: "doc.plaintext")
                    }
                    .buttonStyle(ColorfulButtonStyle())

                    Spacer()

                    Button("Dismiss") {
                        dismiss()
                    }
                    .buttonStyle(ColorfulButtonStyle())
                }

            } header: {
                Text("Changelog")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .formStyle(.grouped)
    }

    var appnamestring: some View {
        Text("Version \(appVersion) build \(appBuild)")
    }

    var copyrightstring: some View {
        Text(copyright)
    }

    var rsyncversionshortstring: some View {
        Text(SharedReference.shared.rsyncversionshort ?? "")
    }

    var rsyncuiconfigpathpath: some View {
        Text("RsyncUI configpath: " + configpath)
    }
}

extension AboutView {
    func openchangelog() {
        NSWorkspace.shared.open(URL(string: changelog)!)
    }
}
