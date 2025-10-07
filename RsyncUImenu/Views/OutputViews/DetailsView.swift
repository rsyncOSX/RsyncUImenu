//
//  DetailsView.swift
//  RsyncUImenu
//
//  Created by Thomas Evensen on 07/06/2024.
//

import SwiftUI

struct DetailsView: View {
    @Environment(\.dismiss) var dismiss

    let remotedatanumbers: RemoteDataNumbers
    let fromsummarizeddetailsview: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                DetailsViewHeading(remotedatanumbers: remotedatanumbers)

                Spacer()

                HStack {
                    if remotedatanumbers.datatosynchronize {
                        VStack(alignment: .leading) {
                            if SharedReference.shared.rsyncversion3 {
                                Text(remotedatanumbers.newfiles_Int == 1 ? "1 new file" : "\(remotedatanumbers.newfiles_Int) new files")
                                Text(remotedatanumbers.deletefiles_Int == 1 ? "1 file for delete" : "\(remotedatanumbers.deletefiles_Int) files for delete")
                            }
                            Text(remotedatanumbers.filestransferred_Int == 1 ? "1 file changed" : "\(remotedatanumbers.filestransferred_Int) files changed")
                            Text(remotedatanumbers.totaltransferredfilessize_Int == 1 ? "byte for transfer" : "\(remotedatanumbers.totaltransferredfilessize_Int) bytes for transfer")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                        }
                        .padding()

                    } else {
                        Text("No data to synchronize")
                            .font(.title2)
                            .padding()
                            .foregroundStyle(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.gradient)
                            }
                            .padding()
                    }

                    if fromsummarizeddetailsview {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "return")
                        }
                        .help("Return")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Output from rsync: \(remotedatanumbers.outputfromrsync?.count ?? 0) rows")
                    .font(.headline)
                    .padding(.horizontal)

                List(remotedatanumbers.outputfromrsync ?? []) { data in
                    Text(data.record)
                        .padding(.vertical, 2)
                }
            }
        }
    }
}
