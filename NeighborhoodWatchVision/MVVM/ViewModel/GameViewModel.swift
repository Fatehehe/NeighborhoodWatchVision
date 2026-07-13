//
//  GameViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Foundation

@MainActor
@Observable
class GameViewModel {
    var encounterRoot = Entity()
    var currentEncounterIndex = 0
    var gameState: GameState = .playing
    
    private var encounters: [EncounterData] = []
    
    func startGame(with data: [EncounterData]) {
        self.encounters = data.shuffled()
        self.currentEncounterIndex = 0
        self.gameState = .playing
        encounterRoot.children.removeAll()
        
        if !encounters.isEmpty {
            spawnEncounter(data: encounters[currentEncounterIndex])
        }
    }
    
    // MARK: - Input Pemain
    func handleButtonPress(entityName: String) {
        print("Button pressed: \(entityName)")
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                
                print("Ada yg lagi di-interogasi nih")
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                
                if entityName == "export3dcoat_001" {
                    print("GateButton diklik nih")
                    
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    
                    // 🎬 Trigger Timeline Masuk
                    notifyTimeline("AnimasiMasuk")
                    
                    if isAnomaly {
                        print("GAME OVER! Anomali berhasil masuk.")
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        return
                    }
                    print("Warga valid. Gerbang dibuka.")
                    
                } else if entityName == "export3dcoat" {
                    print("AlarmButton diklik nih")
                    
                    if !isAnomaly {
                        print("Peringatan: Kamu mengusir warga asli!")
                    } else {
                        print("Kerja bagus! Anomali berhasil diusir.")
                    }
                    
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                    
                    // 🎬 Trigger Timeline Diusir
                    notifyTimeline("AnimasiKeluar")
                }
                
                // Tunggu sampai NPC dihapus oleh Action "Remove from Scene" di RCP
                Task {
                    while npc.scene != nil {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                    spawnNextEncounter()
                }
                break
            }
        }
    }
    
    func handleNpcArrived() {
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .walkingToPost {
                
                encounterComp.state = .interrogated
                npc.components.set(encounterComp)
                print("State NPC sekarang: Interrogated. Menunggu tombol ditekan...")
                break
            }
        }
    }
    
    func notifyTimeline(_ identifier: String) {
        guard let scene = encounterRoot.scene else {
            print("Scene belum tersedia!")
            return
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("RealityKit.NotificationTrigger"),
            object: nil,
            userInfo: [
                "RealityKit.NotificationTrigger.Scene": scene,
                "RealityKit.NotificationTrigger.Identifier": identifier
            ]
        )
    }
    
    private func spawnNextEncounter() {
        guard case .playing = gameState else { return }
        currentEncounterIndex += 1
        
        if currentEncounterIndex < encounters.count {
            spawnEncounter(data: encounters[currentEncounterIndex])
        } else {
            print("Shift selesai! Waktu menunjukkan 05.00.")
            gameState = .won
        }
    }
    
    private func spawnEncounter(data: EncounterData) {
        Task {
            do {
                let npcEntity = try await Entity(named: "Assets/Fatih", in: realityKitContentBundle)
                npcEntity.components.set(ActiveEncounterComponent(
                    data: data,
                    state: .walkingToPost
                ))
                encounterRoot.addChild(npcEntity)
            } catch {
                print("Gagal memuat model dari RCP: \(error)")
            }
        }
    }
}
