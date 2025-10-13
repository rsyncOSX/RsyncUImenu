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
        Table(progressdetails.estimatedlist ?? [],
              selection: $selecteduuids)
        {
            // Synchronize ID column
            TableColumn("Synchronize ID") { data in
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
            .width(min: 100, ideal: 150, max: 200)
            
            // Source folder column
            TableColumn("Source folder") { data in
                Text(data.localCatalog)
                    .lineLimit(1)
            }
            .width(min: 100, ideal: 150, max: 200)
        }
    }
    var rightcolumndetails: some View {
        Table(progressdetails.estimatedlist ?? [],
              selection: $selecteduuids)
        {
            // New column
            TableColumn("New") { files in
                Text(files.newfiles)
                    .foregroundColor(files.datatosynchronize ? .blue : nil)
            }
            .width(min: 40, ideal: 55, max: 70)
            .alignment(.trailing)
            
            // Delete column
            TableColumn("Delete") { files in
                Text(files.deletefiles)
                    .foregroundColor(files.datatosynchronize ? .blue : nil)
            }
            .width(min: 40, ideal: 55, max: 70)
            .alignment(.trailing)
            
            // Updates column
            TableColumn("Updates") { files in
                Text(files.filestransferred)
                    .foregroundColor(files.datatosynchronize ? .blue : nil)
            }
            .width(min: 50, ideal: 55, max: 80)
            .alignment(.trailing)
            
            // kB trans column
            TableColumn("kB trans") { files in
                Text("\(files.totaltransferredfilessize_Int / 1000)")
                    .foregroundColor(files.datatosynchronize ? .blue : nil)
            }
            .width(min: 70, ideal: 80, max: 100)
            .alignment(.trailing)
            
            // Tot files column
            TableColumn("Tot files") { files in
                Text(files.numberoffiles)
            }
            .width(min: 70, ideal: 80, max: 100)
            .alignment(.trailing)
            
            // Tot kB column
            TableColumn("Tot kB") { files in
                Text("\(files.totalfilesize_Int / 1000)")
            }
            .width(min: 70, ideal: 80, max: 100)
            .alignment(.trailing)
        }
    }
}
