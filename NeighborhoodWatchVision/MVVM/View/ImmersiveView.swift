//
//  ImmersiveView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

enum GameState {
    case playing
    case won
    case lost(reason: String)
}

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
        
        @State private var encounterRoot = Entity()
        @State private var currentEncounterIndex = 0
        @State private var gameState: GameState = .playing

        var body: some View {
            RealityView { content, attachments in
                ActiveEncounterComponent.registerComponent()
                MoveToTargetComponent.registerComponent()
                MovementSystem.registerSystem()
                
                content.add(encounterRoot)
                setupSecurityDesk(in: encounterRoot)
                
                if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                    content.add(immersiveContentEntity)
                }
                
                if let encounters = appModel.gameData?.encounters, !encounters.isEmpty {
                    spawnEncounter(data: encounters[currentEncounterIndex])
                }
                
                let headAnchor = AnchorEntity(.head)
                content.add(headAnchor)
                
                if let hudEntity = attachments.entity(for: "GameHUD") {
                    hudEntity.position = SIMD3<Float>(0, 0, -0.4)
                    headAnchor.addChild(hudEntity)
                }
                
            } update: { content, attachments in
                
            } attachments: {
                Attachment(id: "GameHUD") {
                    HUDView(gameState: gameState)
                }
            }
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        guard case .playing = gameState else { return }
                        let tappedEntity = value.entity
                        handleButtonPress(entityName: tappedEntity.name)
                    }
            )
        }
    
    private func spawnEncounter(data: EncounterData) {
        let mesh = MeshResource.generateCylinder(height: 1.8, radius: 0.3)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let npcEntity = ModelEntity(mesh: mesh, materials: [material])
        
        npcEntity.position = SIMD3<Float>(0, 0, -5.0)
        npcEntity.components.set(ActiveEncounterComponent(data: data, state: .walkingToPost))
        npcEntity.components.set(MoveToTargetComponent(
            targetPosition: SIMD3<Float>(0, 0, -1.0),
            speed: 1.0
        ))
        
        encounterRoot.addChild(npcEntity)
        print("Spawned encounter: \(data.idCardData.printedName) from scenario: \(data.scenarioName)")
    }
    
    private func setupSecurityDesk(in root: Entity) {
        // Tombol Buka Gerbang (Contoh pakai kotak hijau)
        let gateMesh = MeshResource.generateBox(size: 0.2)
        let gateMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let gateButton = ModelEntity(mesh: gateMesh, materials: [gateMaterial])
        
        gateButton.position = SIMD3<Float>(-0.3, 1.0, -0.6)
        gateButton.name = "GateButton"
        
        // Wajib untuk interaksi VisionOS
        gateButton.components.set(InputTargetComponent())
        gateButton.components.set(CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])]))
        
        // Tombol Alarm (Contoh pakai kotak merah)
        let alarmMesh = MeshResource.generateBox(size: 0.2)
        let alarmMaterial = SimpleMaterial(color: .red, isMetallic: false)
        let alarmButton = ModelEntity(mesh: alarmMesh, materials: [alarmMaterial])
        
        alarmButton.position = SIMD3<Float>(0.3, 1.0, -0.6)
        alarmButton.name = "AlarmButton"
        
        alarmButton.components.set(InputTargetComponent())
        alarmButton.components.set(CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])]))
        
        root.addChild(gateButton)
        root.addChild(alarmButton)
    }
    
    private func handleButtonPress(entityName: String) {
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                
                if entityName == "GateButton" {
                    if isAnomaly {
                        print("GAME OVER! Anomali berhasil masuk.")
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        encounterComp.state = .entered
                        npc.components.set(encounterComp)
                        npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(0, 0, 5.0), speed: 1.0))
                        return
                    }
                    
                    print("Warga valid. Gerbang dibuka.")
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(0, 0, 5.0), speed: 1.0))
                    
                } else if entityName == "AlarmButton" {
                    if !isAnomaly {
                        print("Peringatan: Kamu mengusir warga asli!")
                    } else {
                        print("Kerja bagus! Anomali berhasil diusir.")
                    }
                    
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(0, 0, -10.0), speed: 2.5))
                }
                
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    spawnNextEncounter()
                }
                break
            }
        }
    }

    private func spawnNextEncounter() {
        guard case .playing = gameState else { return }
        
        currentEncounterIndex += 1
        
        if let encounters = appModel.gameData?.encounters {
            if currentEncounterIndex < encounters.count {
                spawnEncounter(data: encounters[currentEncounterIndex])
            } else {
                print("Shift selesai! Waktu menunjukkan 05.00.")
                gameState = .won
            }
        }
    }
}

struct HUDView: View {
    var gameState: GameState
    var timeString: String = "00.00"
    var subtitleText: String = "Malam pak, nyari siapa ya?"
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(timeString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            Spacer()
            
            if !subtitleText.isEmpty {
                Text(subtitleText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
            }
        }
        .frame(width: 1000, height: 600)
    }
}
