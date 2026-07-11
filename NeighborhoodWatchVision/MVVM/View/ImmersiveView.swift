//
//  ImmersiveView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

// Enum GameState bisa tetap di luar, atau kamu pindahkan ke file model terpisah
enum GameState {
    case playing
    case won
    case lost(reason: String)
}

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    // Inisialisasi ViewModel
    @State private var viewModel = GameViewModel()

    var body: some View {
        RealityView { content, attachments in
            // 1. Setup ECS
            ActiveEncounterComponent.registerComponent()
            MoveToTargetComponent.registerComponent()
            MovementSystem.registerSystem()
            
            // 2. Tambahkan root dari ViewModel ke dalam scene
            content.add(viewModel.encounterRoot)
            
            // 3. Muat lingkungan 3D
            if let world = await SceneSpawner.spawnWorld() {
                content.add(world)
            }
            
            // 4. Mulai game jika data tersedia
            if let encounters = appModel.gameData?.encounters, !encounters.isEmpty {
                viewModel.startGame(with: encounters)
            }
            
            // 5. Setup HUD
            let headAnchor = AnchorEntity(.head)
            content.add(headAnchor)
            
            if let hudEntity = attachments.entity(for: "GameHUD") {
                hudEntity.position = SIMD3<Float>(0, 0, -0.4)
                headAnchor.addChild(hudEntity)
            }
            
        } update: { content, attachments in
            
        } attachments: {
            Attachment(id: "GameHUD") {
                // Gunakan state dari viewModel
                HUDView(gameState: viewModel.gameState)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Validasi dan teruskan input ke ViewModel
                    guard case .playing = viewModel.gameState else { return }
                    viewModel.handleButtonPress(entityName: value.entity.name)
                    print("name of the button \(value.entity.name)")
                }
        )
    }
}
