//
//  ObservableLogSettings.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 13/09/2024.
//

import Foundation
import Observation

@Observable @MainActor
final class ObservableLogSettings {
    // Detailed logging
    var addsummarylogrecord: Bool = SharedReference.shared.addsummarylogrecord
    // Check for network changes
    var monitornetworkconnection: Bool = SharedReference.shared.monitornetworkconnection
    // Check for "error" in output from rsync
    var checkforerrorinrsyncoutput: Bool = SharedReference.shared.checkforerrorinrsyncoutput
    // Automatic execution of estimated tasks
    var confirmexecute: Bool = SharedReference.shared.confirmexecute
    // Synchronize without time delay URL actions
    var synchronizewithouttimedelay: Bool = SharedReference.shared.synchronizewithouttimedelay
    // Toggle sidebar hidden on/off
    var sidebarishidden: Bool = SharedReference.shared.sidebarishidden
    // Observe mounting local atteched discs
    var observemountedvolumes: Bool = SharedReference.shared.observemountedvolumes
    // Always show the summarized estimated view
    var alwaysshowestimateddetailsview: Bool = SharedReference.shared.alwaysshowestimateddetailsview
    // Hide Verify Remote view
    var hideverifyremotefunction: Bool = SharedReference.shared.hideverifyremotefunction
    // Hide Calendar
    var hideschedule: Bool = SharedReference.shared.hideschedule
}
