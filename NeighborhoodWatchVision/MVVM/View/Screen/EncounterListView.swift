//
//  EncounterListView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

struct EncounterListView: View {
    let encounters: [EncounterData]
    
    var body: some View {
        NavigationStack {
            List(encounters) { encounter in
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 12) {
                        // KTP Data
                        GroupBox("Data KTP") {
                            VStack(alignment: .leading) {
                                Text("Nama: \(encounter.idCardData.printedName)")
                                Text("Alamat: \(encounter.idCardData.printedAddress)")
                                Text("Kedaluwarsa: \(encounter.idCardData.expirationDate)")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // LLM Prompt
                        GroupBox("LLM Prompt Context") {
                            VStack(alignment: .leading) {
                                Text("Role: \(encounter.llmPromptContext.roleType.rawValue.uppercased())")
                                    .bold()
                                    .foregroundColor(encounter.llmPromptContext.roleType == .anomaly ? .red : .green)
                                Text("Instruksi: \(encounter.llmPromptContext.behavioralInstruction)")
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 4)
                } label: {
                    VStack(alignment: .leading) {
                        Text(encounter.scenarioName)
                            .font(.headline)
                            .foregroundColor(encounter.llmPromptContext.roleType == .anomaly ? .red : .primary)
                        Text(encounter.encounterID)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Antrean Karakter")
        }
    }
}
