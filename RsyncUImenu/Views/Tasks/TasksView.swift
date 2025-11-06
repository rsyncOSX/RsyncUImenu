//
//  TasksView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 10/11/2023.
//

import Observation
import OSLog
import SwiftUI

struct TasksView: View {
    @Bindable var rsyncUIdata: RsyncUIconfigurations
    // The object holds the progressdata for the current estimated task
    // which is executed. Data for progressview.
    @Bindable var progressdetails: ProgressDetails
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>
    // Navigation path for executetasks
    @Binding var executetaskpath: [Tasks]
    // Show or hide Toolbox
    @Binding var columnVisibility: NavigationSplitViewVisibility
    // Selected profile
    @Binding var selectedprofileID: ProfilesnamesRecord.ID?

    // Local data for present local and remote info about task
    @State var selectedconfig: SynchronizeConfiguration?
    @State private var doubleclick: Bool = false
    // Progress synchronizing
    @State private var progress: Double = 0
    // Not used, only for parameter
    @State private var maxcount: Double = 0
    // For estimates is true
    @State private var thereareestimates: Bool = false
    //
    @State private var selectprofiles: Bool = true

    var body: some View {
        HStack {
            ListofTasksMainView(
                rsyncUIdata: rsyncUIdata,
                selecteduuids: $selecteduuids,
                doubleclick: $doubleclick,
                progress: $progress,
                progressdetails: progressdetails,
                max: maxcount
            )
            .onAppear {
                Task {
                    try await Task.sleep(seconds: 1)
                    selectprofiles = false
                }
            }
            .frame(maxWidth: .infinity)
            .onChange(of: selecteduuids) {
                if let configurations = rsyncUIdata.configurations {
                    if let index = configurations.firstIndex(where: { $0.id == selecteduuids.first }) {
                        selectedconfig = configurations[index]
                        // Must check if rsync version and snapshot
                        if configurations[index].task == SharedReference.shared.snapshot,
                           SharedReference.shared.rsyncversion3 == false
                        {
                            selecteduuids.removeAll()
                        }
                    } else {
                        selectedconfig = nil
                    }
                }
                progressdetails.uuidswithdatatosynchronize = selecteduuids
            }
            .onChange(of: rsyncUIdata.profile) {
                reset()
            }
            .onChange(of: progressdetails.estimatedlist) {
                if progressdetails.estimatedlist == nil {
                    thereareestimates = false
                } else {
                    thereareestimates = true
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            if doubleclick { doubleclickaction }
        }

        Spacer()

        HStack {
            Picker("", selection: $selectedprofileID) {
                Text("Default")
                    .tag(nil as ProfilesnamesRecord.ID?)
                ForEach(rsyncUIdata.validprofiles, id: \.self) { profile in
                    Text(profile.profilename)
                        .tag(profile.id)
                }
            }
            .frame(width: 180)
            // .padding([.bottom, .top, .trailing], 7)
            .disabled(selectprofiles)
            
            ConditionalGlassButton(
                systemImage: "wand.and.stars",
                helpText: "Estimate (⌘E)"
            ) {
                guard SharedReference.shared.norsync == false else { return }
                guard alltasksarehalted() == false else { return }
                // This only applies if one task is selected and that task is halted
                // If more than one task is selected, any halted tasks are ruled out
                if let selectedconfig {
                    guard selectedconfig.task != SharedReference.shared.halted else {
                        Logger.process.info("TasksView: MAGIC WAND button selected task is halted, bailing out")
                        return
                    }
                }
                guard selecteduuids.count > 0 || rsyncUIdata.configurations?.count ?? 0 > 0 else {
                    Logger.process.info("TasksView: MAGIC WAND button no tasks selected, no configurations, bailing out")
                    return
                }

                executetaskpath.append(Tasks(task: .summarizeddetailsview))
            }

            ConditionalGlassButton(
                systemImage: "play.fill",
                helpText: "Synchronize (⌘R)"
            ) {
                guard SharedReference.shared.norsync == false else { return }
                guard alltasksarehalted() == false else { return }
                // This only applies if one task is selected and that task is halted
                // If more than one task is selected, any halted tasks are ruled out
                if let selectedconfig {
                    guard selectedconfig.task != SharedReference.shared.halted else {
                        Logger.process.info("TasksView: PLAY button selected task is halted, bailing out")
                        return
                    }
                }

                guard selecteduuids.count > 0 || rsyncUIdata.configurations?.count ?? 0 > 0 else {
                    Logger.process.info("TasksView: PLAY button selected, no configurations, bailing out")
                    return
                }
                // Check if there are estimated tasks, if true execute the
                // estimated tasks view
                if progressdetails.estimatedlist?.count ?? 0 > 0 {
                    executetaskpath.append(Tasks(task: .executestimatedview))
                } else {
                    execute()
                }
            }
            
            ConditionalGlassButton(
                systemImage: "clear",
                helpText: "Reset estimates"
            ) {
                selecteduuids.removeAll()
                reset()
            }
            

            ConditionalGlassButton(
                systemImage: "text.magnifyingglass",
                helpText: "Rsync output estimated task"
            ) {
                guard selecteduuids.count > 0 else { return }
                guard alltasksarehalted() == false else { return }

                guard selecteduuids.count == 1 else {
                    executetaskpath.append(Tasks(task: .summarizeddetailsview))
                    return
                }
                
                if selecteduuids.count == 1 {
                    guard selectedconfig?.task != SharedReference.shared.halted else {
                        return
                    }
                }
                
                if progressdetails.tasksareestimated(selecteduuids) {
                    executetaskpath.append(Tasks(task: .dryrunonetaskalreadyestimated))
                } else {
                    executetaskpath.append(Tasks(task: .onetaskdetailsview))
                }
            }
            
            ConditionalGlassButton(
                systemImage: "doc.plaintext",
                helpText: "View logfile"
            ) {
                executetaskpath.append(Tasks(task: .viewlogfile))
            }
            
            ConditionalGlassButton(
                systemImage: "chart.bar.fill",
                helpText: "Charts"
            ) {
                executetaskpath.append(Tasks(task: .charts))
            }
            .disabled(selecteduuids.count != 1 || selectedconfig?.task == SharedReference.shared.syncremote)
            
           
            Spacer()
            
            if #available(macOS 26.0, *) {
               
                    Button("Quit", role: .close) {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(RefinedGlassButtonStyle())
              
            } else {
                
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Image(systemName: "Quit")
                    }
                    .help("Close")
                    .buttonStyle(.borderedProminent)
                
            }
        }
        .navigationTitle("Synchronize: profile \(rsyncUIdata.profile ?? "Default")")
    }

    var doubleclickaction: some View {
        Label("", systemImage: "play.fill")
            .foregroundColor(.black)
            .onAppear {
                doubleclickactionfunction()
                doubleclick = false
            }
    }
}

extension TasksView {
    private func alltasksarehalted() -> Bool {
        let haltedtasks = rsyncUIdata.configurations?.filter { $0.task == SharedReference.shared.halted }
        return haltedtasks?.count ?? 0 == rsyncUIdata.configurations?.count ?? 0
    }

    // Double click action is discovered in the ListofTasksMainView
    // Must do some checks her as well
    func doubleclickactionfunction() {
        guard SharedReference.shared.norsync == false else { return }
        // Must check if task is halted
        guard selectedconfig?.task != SharedReference.shared.halted else {
            Logger.process.info("Doubleclick: task is halted")
            return
        }

        if progressdetails.estimatedlist == nil {
            dryrun()
        } else if progressdetails.onlyselectedtaskisestimated(selecteduuids) {
            // Only execute task if this task only is estimated
            Logger.process.info("Doubleclick: execute a real run for one task only")
            execute()
        } else {
            dryrun()
        }
    }

    func dryrun() {
        if selectedconfig != nil,
           progressdetails.estimatedlist?.count ?? 0 == 0
        {
            Logger.process.info("TasksView: DryRun() execute a dryrun for one task only")
            doubleclick = false
            executetaskpath.append(Tasks(task: .onetaskdetailsview))
        } else if selectedconfig != nil,
                  progressdetails.executeanotherdryrun(rsyncUIdata.profile) == true
        {
            Logger.process.info("TasksView: DryRun() new task same profile selected, execute a dryrun")
            doubleclick = false
            executetaskpath.append(Tasks(task: .onetaskdetailsview))

        } else if selectedconfig != nil,
                  progressdetails.alltasksestimated(rsyncUIdata.profile) == false
        {
            Logger.process.info("TasksView: DryRun() profile is changed, new task selected, execute a dryrun")
            doubleclick = false
            executetaskpath.append(Tasks(task: .onetaskdetailsview))
        }
    }

    func execute() {
        // All tasks are estimated and ready for execution.
        if selecteduuids.count == 0,
           progressdetails.alltasksestimated(rsyncUIdata.profile) == true

        {
            Logger.process.info("TasksView: Execute() ALL estimated tasks")
            // Execute all estimated tasks
            selecteduuids = progressdetails.getuuidswithdatatosynchronize()
            // Change view, see SidebarTasksView
            executetaskpath.append(Tasks(task: .executestimatedview))

        } else if selecteduuids.count >= 1,
                  progressdetails.tasksareestimated(selecteduuids) == true

        {
            // One or some tasks are selected and estimated
            Logger.process.info("TasksView: Execute() ESTIMATED tasks only")
            // Execute estimated tasks only
            selecteduuids = progressdetails.getuuidswithdatatosynchronize()
            // Change view, see SidebarTasksView
            executetaskpath.append(Tasks(task: .executestimatedview))

        } else {
            // Execute all tasks, no estimate
            Logger.process.info("TasksView: Execute() selected or all tasks NO ESTIMATE")
            // Execute tasks, no estimate, ask to execute
            executetaskpath.append(Tasks(task: .executenoestimatetasksview))
        }
    }

    func reset() {
        progressdetails.resetcounts()
        selectedconfig = nil
        thereareestimates = false
    }
}
