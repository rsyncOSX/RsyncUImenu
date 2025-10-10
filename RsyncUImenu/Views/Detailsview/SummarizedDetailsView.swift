//
//  SummarizedDetailsView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 10/11/2023.
//

import OSLog
import SwiftUI

struct SummarizedDetailsView: View {
    @Bindable var progressdetails: ProgressDetails
    @Binding var selecteduuids: Set<SynchronizeConfiguration.ID>
    // Navigation path for executetasks
    @Binding var executetaskpath: [Tasks]

    @State private var isPresentingConfirm: Bool = false
    @State private var showdetails: Bool = false

    let configurations: [SynchronizeConfiguration]
    let profile: String?

    var body: some View {
        VStack {
            HStack {
                if progressdetails.estimatealltasksinprogress {
                    EstimationInProgressView(progressdetails: progressdetails,
                                             selecteduuids: $selecteduuids,
                                             profile: profile,
                                             configurations: configurations)
                        .onDisappear {
                            let datatosynchronize = progressdetails.estimatedlist?.compactMap { element in
                                element.datatosynchronize ? true : nil
                            }
                            if let datatosynchronize {
                                if datatosynchronize.count == 0,
                                   SharedReference.shared.alwaysshowestimateddetailsview == false
                                {
                                    executetaskpath.removeAll()
                                }
                            }
                        }
                } else {
                    ZStack {
                        HStack {
                            leftcolumndetails

                            rightcolumndetails
                        }

                        if datatosynchronize, selecteduuids.count == 0 {
                            if SharedReference.shared.confirmexecute {
                                Button {
                                    isPresentingConfirm = progressdetails.confirmexecutetasks()
                                    if isPresentingConfirm == false {
                                        executetaskpath.removeAll()
                                        executetaskpath.append(Tasks(task: .executestimatedview))
                                    }
                                } label: {
                                    Text(Image(systemName: "play.fill"))
                                        .font(.title2)
                                        .imageScale(.large)
                                }
                                .buttonStyle(.borderedProminent)
                                .help("Synchronize (⌘R)")
                                .confirmationDialog("Synchronize tasks?",
                                                    isPresented: $isPresentingConfirm)
                                {
                                    Button("Synchronize", role: .destructive) {
                                        executetaskpath.removeAll()
                                        executetaskpath.append(Tasks(task: .executestimatedview))
                                    }
                                }

                            } else {
                                Button {
                                    executetaskpath.removeAll()
                                    executetaskpath.append(Tasks(task: .executestimatedview))
                                } label: {
                                    Text(Image(systemName: "play.fill"))
                                        .imageScale(.large)
                                        .font(.title2)
                                }
                                .help("Synchronize (⌘R)")
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .frame(maxWidth: .infinity)
            .onChange(of: selecteduuids) {
                guard selecteduuids.count == 1 else { return }
                showdetails = true
            }
            .onAppear {
                Logger.process.info("SummarizedDetailsView: ONAPPEAR")
                guard progressdetails.estimatealltasksinprogress == false else {
                    Logger.process.warning("SummarizedDetailsView: estimate already in progress")
                    return
                }
                if progressdetails.estimatedlist?.count ?? 0 == 0 {
                    progressdetails.resetcounts()
                    progressdetails.startestimation()
                }
            }
        }
        .sheet(isPresented: $showdetails) {
            if let estimates = progressdetails.estimatedlist?.filter({ $0.id == selecteduuids.first }) {
                if estimates.count == 1 {
                    DetailsView(remotedatanumbers: estimates[0], fromsummarizeddetailsview: true)
                        .frame(width: 900, height: 400)
                        .presentationDetents([.height(400)])
                        .presentationBackground(.ultraThinMaterial)
                    // .presentationCornerRadius(8)
                }
            }
        }
    }

    var datatosynchronize: Bool {
        if progressdetails.estimatealltasksinprogress == false {
            let datatosynchronize = progressdetails.estimatedlist?.filter { $0.datatosynchronize == true }
            if (datatosynchronize?.count ?? 0) > 0 {
                return true
            } else {
                return false
            }
        }
        return false
    }

    var leftcolumndetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Headers
            HStack(spacing: 12) {
                Text("Synchronize ID")
                    .frame(maxWidth: 150, alignment: .leading)
                    .font(.headline)
                
                Text("Source folder")
                    .frame(minWidth: 100, maxWidth: 150, alignment: .leading)
                    .font(.headline)
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Divider()
            
            // List Content
            List(progressdetails.estimatedlist ?? [],
                 selection: $selecteduuids)
            { data in
                HStack(spacing: 12) {
                    // Synchronize ID section
                    Group {
                        if data.datatosynchronize {
                            if data.backupID.isEmpty == true {
                                Text("Synchronize ID")
                                    .foregroundColor(.blue)
                            } else {
                                Text(data.backupID)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            if data.backupID.isEmpty == true {
                                Text("Synchronize ID")
                            } else {
                                Text(data.backupID)
                            }
                        }
                    }
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 150, alignment: .leading)

                    // Source folder
                    Text(data.localCatalog)
                        .frame(minWidth: 100, maxWidth: 150, alignment: .leading)
                        .lineLimit(1)

                    /*
                     // Server
                     Text(data.offsiteServer.count > 0 ? data.offsiteServer : "localhost")
                         .frame(maxWidth: 100, alignment: .leading)
                     */
                    Spacer()
                }
                .padding(.vertical, -4)
            }
        }
    }

    var rightcolumndetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Headers
            HStack(spacing: 8) {
                Text("New")
                    .frame(width: 55, alignment: .trailing)
                    .font(.headline)
                
                Text("Delete")
                    .frame(width: 55, alignment: .trailing)
                    .font(.headline)
                
                Text("Updates")
                    .frame(width: 55, alignment: .trailing)
                    .font(.headline)
                
                Text("kB trans")
                    .frame(width: 80, alignment: .trailing)
                    .font(.headline)
                
                Text("Tot files")
                    .frame(width: 80, alignment: .trailing)
                    .font(.headline)
                
                Text("Tot kB")
                    .frame(width: 80, alignment: .trailing)
                    .font(.headline)
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Divider()
            
            // List Content
            List(progressdetails.estimatedlist ?? [],
                 selection: $selecteduuids)
            { files in
                HStack(spacing: 8) {
                    // New
                    Text(files.newfiles)
                        .frame(width: 40, alignment: .trailing)
                        .foregroundColor(files.datatosynchronize ? .blue : nil)

                    // Delete
                    Text(files.deletefiles)
                        .frame(width: 40, alignment: .trailing)
                        .foregroundColor(files.datatosynchronize ? .blue : nil)

                    // Updates
                    Text(files.filestransferred)
                        .frame(width: 55, alignment: .trailing)
                        .foregroundColor(files.datatosynchronize ? .blue : nil)

                    // kB trans
                    Text("\(files.totaltransferredfilessize_Int / 1000)")
                        .frame(width: 80, alignment: .trailing)
                        .foregroundColor(files.datatosynchronize ? .blue : nil)

                    // Tot files
                    Text(files.numberoffiles)
                        .frame(width: 80, alignment: .trailing)

                    // Tot kB
                    Text("\(files.totalfilesize_Int / 1000)")
                        .frame(width: 80, alignment: .trailing)

                    Spacer()
                }
                .padding(.vertical, -4)
            }
        }
    }
}
