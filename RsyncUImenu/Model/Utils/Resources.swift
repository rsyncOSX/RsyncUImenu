//
//  Resources.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// Enumtype type of resource
enum ResourceType {
    case changelog
    case documents
    case urlJSON
}

struct Resources {
    // Resource strings
    private var changelog: String = "https://rsyncui.netlify.app/blog/"
    private var documents: String = "https://rsyncui.netlify.app/docs/"
    private var urlJSON: String = "https://raw.githubusercontent.com/rsyncOSX/RsyncUImenu/master/versionRsyncUImenu/versionRsyncUImenusonoma.json"
    // Get the resource.
    func getResource(resource: ResourceType) -> String {
        switch resource {
        case .changelog:
            changelog
        case .documents:
            documents
        case .urlJSON:
            urlJSON
        }
    }
}

//  swiftlint:enable line_length
