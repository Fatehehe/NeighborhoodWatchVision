//
//  InterrogationView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

struct InterrogationView: View {
    @Environment(AppModel.self) var appModel
    
    // Inisialisasi ViewModel secara lokal untuk tab ini
    @State private var encounterVM = EncounterViewModel()
    
    // State baru untuk menampung input teks
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pos Penjagaan: Interogasi")
                .font(.largeTitle)
                .bold()
            
            // STATE 1: MODEL SEDANG LOADING
            if encounterVM.isLoading {
                VStack(spacing: 10) {
                    ProgressView(encounterVM.loadingStatus, value: encounterVM.downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                    Text("\(Int(encounterVM.downloadProgress * 100))%")
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: 400)
            }
            // STATE 2: MODEL BELUM DILOAD
            else if !encounterVM.isModelLoaded {
                Button("Nyalakan Sistem AI Pos") {
                    Task {
                        await encounterVM.loadModel()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            // STATE 3: MODEL SIAP BERAKSI
            else {
                HStack(alignment: .top, spacing: 30) {
                    // KOLOM KIRI: UI Karakter
                    GroupBox {
                        if let activeChar = encounterVM.activeEncounter {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(activeChar.scenarioName)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(activeChar.llmPromptContext.roleType == .anomaly ? .red : .primary)
                                    Spacer()
                                    Button("Next Character") {
                                        encounterVM.startNextEncounter()
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                Divider()
                                
                                ScrollView {
                                    Text(encounterVM.npcDialogue.isEmpty ? "..." : encounterVM.npcDialogue)
                                        .font(.title3)
                                        .italic()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(height: 120)
                                
                                if encounterVM.isNPCThinking {
                                    ProgressView("Karakter sedang berpikir...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(8)
                        } else {
                            VStack(spacing: 15) {
                                Text("Tidak ada orang di depan pos.")
                                    .foregroundColor(.secondary)
                                Button("Panggil Antrean Pertama") {
                                    encounterVM.startNextEncounter()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                        }
                    }
                    .frame(maxWidth: 500)
                    
                    // KOLOM KANAN: UI Input Teks (Player) & Logs
                    VStack(spacing: 15) {
                        GroupBox("Input Interogasi") {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Ketik pertanyaan di sini...", text: $inputText)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(encounterVM.isNPCThinking)
                                    // Memungkinkan pengiriman teks saat menekan Enter/Return
                                    .onSubmit {
                                        sendInterrogation()
                                    }
                                
                                Button("Kirim Pertanyaan") {
                                    sendInterrogation()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || encounterVM.isNPCThinking)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                        }
                        
                        DisclosureGroup("System Logs") {
                            ScrollView {
                                Text(encounterVM.logText)
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 100)
                        }
                    }
                    .frame(maxWidth: 350)
                }
            }
        }
        .padding(30)
        .onAppear {
            // Sambungkan data antrean dari AppModel ke EncounterVM
            if let gameData = appModel.gameData, encounterVM.encounterQueue.isEmpty {
                encounterVM.setupQueue(encounters: gameData.encounters)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func sendInterrogation() {
        let textToSend = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }
        
        // Kosongkan text field setelah di-submit
        inputText = ""
        
        // Tembak teks ke LLM
        Task {
            await encounterVM.interactWithNPC(playerSpeech: textToSend)
        }
    }
}

