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
    var worldRoot: Entity?
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
    
    // Di dalam GameViewModel.swift
        func restartGame() {
            print("Merestart Game...")
            
            // 1. Bersihkan sisa NPC yang mungkin masih ada
            encounterRoot.children.removeAll()
            
            // 2. Tutup gerbang (jika tadi game over saat gerbang masih terbuka)
            if let world = worldRoot,
               let leftGate = world.findEntity(named: "Left_Gate"),
               var leftGateComp = leftGate.components[GateComponent.self],
               let rightGate = world.findEntity(named: "Right_Gate"),
               var rightGateComp = rightGate.components[GateComponent.self] {
                
                leftGateComp.state = .closed
                rightGateComp.state = .closed
                
                leftGate.transform.rotation = leftGateComp.closedRotation
                rightGate.transform.rotation = rightGateComp.closedRotation
                
                leftGate.components.set(leftGateComp)
                rightGate.components.set(rightGateComp)
            }
            
            // 3. Mulai ulang
            startGame(with: self.encounters)
        }
    
    // MARK: - Input Pemain
    func handleButtonPress(entityName: String) {
        print("Button pressed: \(entityName)")
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                
                print("Ada yg lagi di-interogasi nih")
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                
                if entityName == "GateButton" || entityName == "export3dcoat_001" {
                    print("GateButton diklik nih")
                    
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    
                    notifyTimeline("Pass")
                    animateGates()
                    
                    if isAnomaly {
                        print("GAME OVER! Anomali berhasil masuk.")
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        return
                    }
                    print("Warga valid. Gerbang dibuka.")
                    
                }
                else if entityName == "AlarmButton" || entityName == "export3dcoat" {
                    print("AlarmButton diklik nih")

                    if !isAnomaly {
                        print("Peringatan: Kamu mengusir warga asli!")
                    } else {
                        print("Kerja bagus! Anomali berhasil diusir.")
                    }
                    
                    notifyTimeline("Out")
                    
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                }
                
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    npc.removeFromParent()
                    spawnNextEncounter()
                }
                
                break
            }
        }
    }
    
    private func animateGates() {
        guard let world = worldRoot,
              let rightGate = world.findEntity(named: "Right_Gate"),
              var rightGateComp = rightGate.components[GateComponent.self],
              let leftGate = world.findEntity(named: "Left_Gate"),
              var leftGateComp = leftGate.components[GateComponent.self] else {
            return
        }
        
        leftGateComp.state = .opening
        rightGateComp.state = .opening
        
        leftGate.components.set(leftGateComp)
        rightGate.components.set(rightGateComp)
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if var currentLeftComp = leftGate.components[GateComponent.self],
               var currentRightComp = rightGate.components[GateComponent.self] {
                
                currentLeftComp.state = .closing
                currentRightComp.state = .closing
                
                leftGate.components.set(currentLeftComp)
                rightGate.components.set(currentRightComp)
            }
        }
    }
    
    func handleNpcArrived() {
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .walkingToPost {
                encounterComp.state = .interrogated
                npc.components.set(encounterComp)
                print("State NPC \(encounterComp.data.scenarioName) sekarang: Interrogated. Menunggu tombol ditekan...")
                break
            }
        }
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
}
