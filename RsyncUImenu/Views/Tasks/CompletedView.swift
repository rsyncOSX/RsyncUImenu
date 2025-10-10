//
//  CompletedView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 20/05/2024.
//

import SwiftUI

struct CompletedView: View {
    // Navigation path for executetasks
    @Binding var executetaskpath: [Tasks]
    @State var showtext: Bool = true

    var body: some View {
        VStack {
            if showtext {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.title)
                    .imageScale(.large)
                    .foregroundColor(.green)
                    .onAppear {
                        Task {
                            try await Task.sleep(seconds: 1)
                            showtext = false
                        }
                    }
                    .onDisappear {
                        executetaskpath.removeAll()
                    }
            }
        }
    }
}
