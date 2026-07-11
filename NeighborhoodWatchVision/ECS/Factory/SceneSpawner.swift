//
//  SceneSpawner.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import RealityKit
import RealityKitContent

public struct SceneSpawner {
    @MainActor
    public static func spawnWorld(name sceneName: String = "Scenes/EnviScene") async -> Entity? {
        do {
            let scene = try await Entity(named: sceneName, in: realityKitContentBundle)
            
            // 1. Putar scene 90 derajat di sumbu Y
            // Float.pi / 2 adalah 90 derajat dalam radian.
            // Jika arahnya terbalik, ubah menjadi -(Float.pi / 2)
            let angle = Float.pi / 2
            scene.orientation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
            scene.position = SIMD3<Float>(0, 0, 0)
            
            print("[MedievalSceneSpawner] Sukses memuat dunia: \(sceneName)")
            
            // 2. Setup Red Button sebagai Alarm
            if let redButton = scene.findEntity(named: "Button_Red"){
                print("Button merah ada! Setup sebagai Alarm.")
                redButton.name = "AlarmButton" // Ubah nama agar match dengan handleButtonPress
                redButton.components.set(InputTargetComponent())
                redButton.generateCollisionShapes(recursive: true) // Buat area tap otomatis
                redButton.components.set(HoverEffectComponent())   // Efek menyala saat dilihat mata
            }
            
            // 3. Setup Green Button sebagai Gate
            if let greenButton = scene.findEntity(named: "Button_Green"){
                print("Button hijau ada! Setup sebagai Gate.")
                greenButton.name = "GateButton" // Ubah nama agar match dengan handleButtonPress
                greenButton.components.set(InputTargetComponent())
                greenButton.generateCollisionShapes(recursive: true)
                greenButton.components.set(HoverEffectComponent())
            }
            
            if let rightGate = scene.findEntity(named: "Right_Gate"){
                print("Right gate ada!")
            }
            
            if let leftGate = scene.findEntity(named: "Left_Gate"){
                print("Left gate ada!")
            }
            
            return scene
        } catch {
            print("[MedievalSceneSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
}
