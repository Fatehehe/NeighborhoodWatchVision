//
//  ResidentListView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

struct ResidentListView: View {
    let residents: [ResidentManifest]
    
    var body: some View {
        NavigationStack {
            List(residents) { resident in
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Pekerjaan:** \(resident.occupation)")
                        Text("**Relasi:** \(resident.relation)")
                        Text("**Kepribadian:** \(resident.personality)")
                        Text("**Secret Lore:** \(resident.secretLore)")
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                } label: {
                    HStack {
                        Text(resident.trueAddress)
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        VStack(alignment: .leading) {
                            Text(resident.trueName).font(.title3).bold()
                            Text(resident.residentID).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Manifest Warga (Source of Truth)")
        }
    }
}
