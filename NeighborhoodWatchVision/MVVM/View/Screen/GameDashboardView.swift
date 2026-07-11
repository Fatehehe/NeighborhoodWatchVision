//
//  GameDashboardView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

struct GameDashboardView: View {
    @Environment(AppModel.self) var model
    
    var body: some View {
        Group {
            if let data = model.gameData {
                TabView {
                    // TAB 1: POS PENJAGAAN (UI INTEROGASI AI)
                    InterrogationView()
                        .tabItem {
                            Label("Pos Jaga", systemImage: "shield.righthalf.filled")
                        }
                    
                    // TAB 2: RESIDENTS (MANIFEST)
                    ResidentListView(residents: data.residents)
                        .tabItem {
                            Label("Warga Asli", systemImage: "person.2.fill")
                        }
                    
                    // TAB 3: ENCOUNTERS (ANOMALIES & RESIDENTS)
                    EncounterListView(encounters: data.encounters)
                        .tabItem {
                            Label("Antrean (Encounters)", systemImage: "list.bullet.rectangle.portrait")
                        }
                    
                    // TAB 4: VILLAGE MAP
                    VillageMapView(houses: Array(data.villageMap.houses.values).sorted(by: { $0.houseID < $1.houseID }))
                        .tabItem {
                            Label("Peta Desa", systemImage: "map.fill")
                        }
                }
            } else {
                ContentUnavailableView(
                    "Data Belum Dimuat",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Menunggu proses decode JSON...")
                )
            }
        }
        .onAppear {
            model.loadGameData()
        }
    }
}

#Preview(windowStyle: .automatic) {
    GameDashboardView()
        .environment(AppModel())
}
