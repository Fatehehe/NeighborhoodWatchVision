//
//  AIPrepView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

struct AIPrepView: View {
    @Environment(AppModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.righthalf.filled")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)
                
                Text("Guard Post")
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)
                
                Text("AI Interrogation System")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)
            
            Group {
                if model.encounterViewModel.isLoading {
                    // State 1: Sedang Loading / Download
                    VStack(spacing: 16) {
                        Text("Initiating AI Model...")
                            .font(.headline)
                        
                        // Disamakan dengan ControlPanelView agar UI update lebih responsif
                        VStack(spacing: 10) {
                            ProgressView(
                                model.encounterViewModel.loadingStatus.isEmpty ? "Preparing data..." : model.encounterViewModel.loadingStatus,
                                value: model.encounterViewModel.downloadProgress,
                                total: 1.0
                            )
                            .progressViewStyle(.linear)
                            .tint(.blue)
                            
                            Text("\(Int(model.encounterViewModel.downloadProgress * 100))%")
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: 400)
                    
                } else if !model.encounterViewModel.isModelLoaded {
                    // State 2: Belum Download
                    VStack(spacing: 16) {
                        Text("The AI system is currently offline. Turn on the system to start your guard shift.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        Button {
                            Task {
                                await model.encounterViewModel.loadModel()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "power")
                                Text("Turn On AI System")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: 400)
                    
                } else {
                    // State 3: Selesai Download
                    VStack(spacing: 24) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            Text("AI System activated")
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                        
                        FrameButton(title: "Start Shift") {
                            Task {
                                model.currentFlow = .playing
                                await openImmersiveSpace(id: model.immersiveSpaceID)
                                dismissWindow()
                            }
                        }
                    }
                }
            }
            // Mengurangi durasi animasi agar tidak bentrok dengan update progress bar yang cepat
            .animation(.easeInOut(duration: 0.2), value: model.encounterViewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: model.encounterViewModel.isModelLoaded)
        }
        .padding(50)
        .frame(width: 600, height: 500)
    }
}
