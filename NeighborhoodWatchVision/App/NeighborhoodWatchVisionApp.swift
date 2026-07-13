//
//  NeighborhoodWatchVisionApp.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI

@main
struct NeighborhoodWatchVisionApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(id: appModel.windowID) {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
     }
}
