//
//  GameViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
@Observable
class GameViewModel {
    // MARK: - Game State
    var encounterRoot = Entity()
    var currentEncounterIndex = 0
    var gameState: GameState = .playing
    
    // Simpan referensi antrean encounter
    private var encounters: [EncounterData] = []
    
    // MARK: - Game Loop
    func startGame(with data: [EncounterData]) {
        // 1. Acak urutan encounters saat game dimulai
        self.encounters = data.shuffled()
        self.currentEncounterIndex = 0
        self.gameState = .playing
        
        // Bersihkan root jika ada sisa NPC dari permainan sebelumnya
        encounterRoot.children.removeAll()
        
        if !encounters.isEmpty {
            spawnEncounter(data: encounters[currentEncounterIndex])
        }
    }
    
    func handleButtonPress(entityName: String) {
        print("Button pressed")
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                print("ada yg lagi introgated nih")
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                
                if entityName == "export3dcoat_001" {
                    print("GateButton diklik nih")
                    if isAnomaly {
                        print("GAME OVER! Anomali berhasil masuk.")
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        
                        encounterComp.state = .entered
                        npc.components.set(encounterComp)
                        // Anomali masuk ke gerbang (Jalan ke Kiri -> X: -5.0)
                        npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(-5.0, 0, -5.0), speed: 1.0))
                        return
                    }
                    
                    print("Warga valid. Gerbang dibuka.")
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    // Warga masuk ke gerbang (Jalan ke Kiri -> X: -5.0)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(-5.0, 0, -5.0), speed: 1.0))
                    
                } else if entityName == "export3dcoat" {
                    print("AlarmButton diklik nih")
                    if !isAnomaly {
                        print("Peringatan: Kamu mengusir warga asli!")
                    } else {
                        print("Kerja bagus! Anomali berhasil diusir.")
                    }
                    
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                    // Diusir kembali ke tempat asal/spawn (Jalan ke Kanan -> X: 5.0)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(5.0, 0, -5.0), speed: 2.5))
                }
                
                // 3. Tunggu sampai NPC benar-benar dihapus dari scene baru spawn yang baru
                Task {
                    // Loop ini akan terus mengecek selama NPC masih ada di dalam scene.
                    // Begitu MovementSystem menjalankan entity.removeFromParent(), npc.scene akan bernilai nil.
                    while npc.scene != nil {
                        try? await Task.sleep(nanoseconds: 100_000_000) // Cek setiap 0.1 detik
                    }
                    spawnNextEncounter()
                }
                break // Cukup proses 1 NPC aktif
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
        let mesh = MeshResource.generateCylinder(height: 1.8, radius: 0.3)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let npcEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // 2. Sesuaikan Posisi Awal dan Target Berhenti
        // Muncul dari Kanan (X: 5.0, Z: -2.0 agar agak di depan pemain)
        npcEntity.position = SIMD3<Float>(5.0, 0, -5.0)
        
        npcEntity.components.set(ActiveEncounterComponent(data: data, state: .walkingToPost))
        
        // Jalan ke tengah (pos satpam di X: 0.0)
        npcEntity.components.set(MoveToTargetComponent(
            targetPosition: SIMD3<Float>(0, 0, -5.0),
            speed: 1.0
        ))
        
        encounterRoot.addChild(npcEntity)
        print("Spawned encounter: \(data.idCardData.printedName) from scenario: \(data.scenarioName)")
    }
}
