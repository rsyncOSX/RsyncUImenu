//
//  SidebarTasksView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 10/11/2023.
//
// swiftlint:disable cyclomatic_complexity

import OSLog
import SwiftUI

enum DestinationView: String, Identifiable {
    case executestimatedview, executenoestimatetasksview,
         summarizeddetailsview, onetaskdetailsview,
         dryrunonetaskalreadyestimated,
         completedview, viewlogfile, charts
    var id: String { rawValue }
}

struct Tasks: Hashable, Identifiable {
    let id = UUID()
    var task: DestinationView
}

struct SidebarTasksView: View {
    @Bindable var rsyncUIdata: RsyncUIconfigurations
    @Bindable var progressdetails: ProgressDetails
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>
    @Binding var executetaskpath: [Tasks]
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    @Binding var selectedprofileID: ProfilesnamesRecord.ID?

    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar - show if we have navigation
            if let currentTask = executetaskpath.last {
                HStack {
                    Button(action: {
                        executetaskpath.removeLast()
                    }) {
                        Label("Back", systemImage: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .padding(5)

                    Spacer()

                    Text(navigationTitle(for: currentTask))
                        .font(.headline)
                        .padding(5)

                    Spacer()
                }
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
            }

            // Show current view based on navigation path
            Group {
                if let currentTask = executetaskpath.last {
                    makeView(view: currentTask.task)
                } else {
                    // Root view
                    TasksView(rsyncUIdata: rsyncUIdata,
                              progressdetails: progressdetails,
                              selecteduuids: $selecteduuids,
                              executetaskpath: $executetaskpath,
                              columnVisibility: $columnVisibility,
                              selectedprofileID: $selectedprofileID)
                }
            }
        }
        .onChange(of: executetaskpath) {
            Logger.process.info("SidebarTasksView: executetaskpath \(executetaskpath, privacy: .public)")
        }
    }

    func navigationTitle(for task: Tasks) -> String {
        switch task.task {
        case .executestimatedview: "Execute Estimated"
        case .executenoestimatetasksview: "Execute Tasks"
        case .summarizeddetailsview: "Summary"
        case .onetaskdetailsview: "Task Details"
        case .dryrunonetaskalreadyestimated: "Details"
        case .completedview: "Completed"
        case .viewlogfile: "Log File"
        case .charts: "Charts"
        }
    }

    @MainActor @ViewBuilder
    func makeView(view: DestinationView) -> some View {
        switch view {
        case .executestimatedview:
            ExecuteEstTasksView(rsyncUIdata: rsyncUIdata,
                                progressdetails: progressdetails,
                                selecteduuids: $selecteduuids,
                                executetaskpath: $executetaskpath)
        case .executenoestimatetasksview:
            ExecuteNoEstTasksView(rsyncUIdata: rsyncUIdata,
                                  selecteduuids: $selecteduuids,
                                  executetaskpath: $executetaskpath)
        case .summarizeddetailsview:
            if let configurations = rsyncUIdata.configurations {
                SummarizedDetailsView(progressdetails: progressdetails,
                                      selecteduuids: $selecteduuids,
                                      executetaskpath: $executetaskpath,
                                      configurations: configurations,
                                      profile: rsyncUIdata.profile)
            }
        case .onetaskdetailsview:
            if let configurations = rsyncUIdata.configurations {
                OneTaskDetailsView(progressdetails: progressdetails,
                                   selecteduuids: selecteduuids,
                                   configurations: configurations)
            }
        case .dryrunonetaskalreadyestimated:
            if let estimates = progressdetails.estimatedlist?.filter({ $0.id == selecteduuids.first }) {
                if estimates.count == 1 {
                    DetailsView(remotedatanumbers: estimates[0], fromsummarizeddetailsview: false)
                        .onDisappear(perform: {
                            selecteduuids.removeAll()
                        })
                }
            }
        case .completedview:
            CompletedView(executetaskpath: $executetaskpath)
                .onAppear {
                    reset()
                }
        case .viewlogfile:
            NavigationLogfileView()
        case .charts:
            LogStatsChartView(rsyncUIdata: rsyncUIdata, selecteduuids: $selecteduuids)
        }
    }

    func reset() {
        progressdetails.resetcounts()
    }
}

// swiftlint:enable cyclomatic_complexity
