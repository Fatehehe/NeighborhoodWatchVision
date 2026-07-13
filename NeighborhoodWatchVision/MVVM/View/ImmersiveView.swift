//
//  ImmersiveView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

enum GameState {
    case playing
    case won
    case lost(reason: String)
}

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var viewModel = GameViewModel()

    var body: some View {
        RealityView { content, attachments in
            ActiveEncounterComponent.registerComponent()
            
            content.add(viewModel.encounterRoot)
            
            if let world = await SceneSpawner.spawnWorld() {
                content.add(world)
            }
            
            if let encounters = appModel.gameData?.encounters, !encounters.isEmpty {
                viewModel.startGame(with: encounters)
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
                HUDView(gameState: viewModel.gameState)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard case .playing = viewModel.gameState else { return }
                    viewModel.handleButtonPress(entityName: value.entity.name)
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))) { notification in
            guard
                let userInfo = notification.userInfo,
                let identifier = userInfo["RealityKit.NotificationTrigger.Identifier"] as? String
            else { return }

            switch identifier {
            case "Arrived":
                print("Timeline RCP mengirim: Arrived")
                viewModel.handleNpcArrived()
            default:
                break
            }
        }
    }
}
