//
//  EncounterViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo
//

import Foundation
import MLX
import MLXLMCommon
import SwiftUI

@Observable @MainActor
public class EncounterViewModel {
    // MARK: - LLM & Loading State
    public var logText: String = ""
    public var isModelLoaded: Bool = false
    public var isLoading: Bool = false
    public var downloadProgress: Double = 0.0
    public var loadingStatus: String = ""
    
    private let llmFactory = LLMFactory() // Factory MLX Swift milikmu
    
    // MARK: - Game Session State
//    var encounterQueue: [EncounterData] = []
//    var activeEncounter: EncounterData? = nil
    public var npcDialogue: String = ""
    public var isNPCThinking: Bool = false
    
    public init() {}
    
    // MARK: - 1. Setup Antrean (Dipanggil dari View menggunakan AppModel)
    func setupQueue(encounters: [EncounterData]) {
//        self.encounterQueue = encounters
        self.logText += "\n[System] Guard system active. Total queue: \(encounters.count) people."
    }
    
    public func resetDialogue() {
        self.npcDialogue = "..."
    }
    
    // MARK: - 2. Load Model AI Lokal
    func loadModel() async {
        guard !isLoading && !isModelLoaded else { return }
        isLoading = true
        logText += "\n[System] Loading Qwen2.5 3B (4-bit)..."
        
        do {
            let _ = try await llmFactory.load { [weak self] progress, status in
                Task { @MainActor in
                    self?.downloadProgress = progress
                    self?.loadingStatus = status
                }
            }
            isModelLoaded = true
            logText += "\n[System] Model Successfully Loaded!"
        } catch {
            logText += "\n[Error] Failed to load model: \(error.localizedDescription)"
            loadingStatus = "Failed"
        }
        isLoading = false
    }
    
    // MARK: - 3. Panggil Karakter Selanjutnya
//    public func startNextEncounter() {
//        guard !encounterQueue.isEmpty else {
//            logText += "\n[System] No more people in queue. Shift is over!"
//            activeEncounter = nil
//            npcDialogue = "Shift is over."
//            return
//        }
//        
//        // Tarik 1 orang dari antrean
//        activeEncounter = encounterQueue.removeFirst()
//        npcDialogue = "..." // Reset UI Bubble Chat
//        logText += "\n[System] Someone approaches: \(activeEncounter!.scenarioName)"
//    }
    
    // MARK: - 4. Interogasi Karakter (Kirim Suara Pemain ke LLM)
    public func interactWithNPC(playerSpeech: String, encounter: EncounterData) async {
        guard isModelLoaded else {
            logText += "\n[Warning] Wait, the AI model is not ready yet!"
            return
        }

        isNPCThinking = true
        npcDialogue = "" // Bersihkan teks lama untuk efek streaming baru
        logText += "\n[Guard/Player]: \(playerSpeech)"
        
        do {
            let container = try await llmFactory.load()
            let context = encounter.llmPromptContext
            let idCard = encounter.idCardData // Tarik data ID Card
            
            // System Prompt yang memasukkan konteks ID Card
            let systemPrompt = """
            You are playing a role in a neighborhood watch simulation game. You are currently standing at the main security gate, being interrogated by the security guard (the player).
            
            ### CURRENT SITUATION
            You have just handed your physical ID card to the guard. They are looking at it right now to verify your identity. You must act as if the information on that ID card is the absolute truth, and you must defend it if the guard is suspicious.
            
            ### ID CARD DATA (WHAT THE GUARD IS HOLDING)
            - Printed Name: \(idCard.printedName)
            - Printed Address: \(idCard.printedAddress)
            - ID Number: \(idCard.printedIDNumber)
            - Expiration Date: \(idCard.expirationDate)
            - Gender: \(idCard.gender)
            - birthDay: \(idCard.birthDay)
            
            ### CHARACTER PROFILE & BELIEFS
            - Claimed Name: \(context.characterName)
            - Believed Occupation: \(context.believedOccupation)
            - Claimed Address: \(context.believedAddress)
            - True Nature: \(context.roleType) (Keep this secret unless forced by logic)
            - Current Objective: \(context.objective)
            
            ### SPATIAL MEMORY & KNOWLEDGE
            \(context.spatialContext)
            
            ### BEHAVIOR & TRIGGER RULES
            \(context.behavioralInstruction)
            
            ### INFORMATION OF WHY ARE YOU HERE
            You know that the player is a security guard. The player's business here is to guard the gate, inspect your ID card, verify your face, and check your story before deciding to open the gate or press the emergency alarm.
            
            ### STRICT ROLEPLAY RULES (YOU MUST OBEY)
            1. DO NOT break character under any circumstances. Never refer to yourself as an AI, assistant, or language model.
            2. NEVER act like a customer service bot. Do not ask "How can I help you?". You are a civilian being questioned by security. Act appropriately (annoyed, nervous, creepy, etc.).
            3. Show, don't just tell. Use your specified personality traits in the way you speak.
            4. React realistically to the guard. If they accuse you of something in your "Trigger Rules", react exactly as instructed (e.g., panic, get defensive, or become arrogant).
            5. If the guard points out a typo, expired date, or wrong address on your ID, defend it based on your character's personality!
            6. CONSTRAINTS: Keep your response conversational and VERY SHORT (Maximum 2-3 sentences).
            """
            
            let chat: [Chat.Message] = [
                .system(systemPrompt),
                .user(playerSpeech)
            ]
            
            let userInput = UserInput(chat: chat)
            let lmInput = try await container.prepare(input: userInput)
            
            let parameters = GenerateParameters(temperature: 0.6)
            let stream = try await container.generate(input: lmInput, parameters: parameters)
            
            var result = ""
            var iterator = stream.makeAsyncIterator()
            while let chunk = await iterator.next() {
                if let text = chunk.chunk {
                    self.npcDialogue += text // Update UI secara real-time
                    result += text
                }
            }
            
            logText += "\n[\(context.characterName)]: \(result)"
            
        } catch {
            logText += "\n[Error] Failed to generate response: \(error.localizedDescription)"
            self.npcDialogue = "*The character stares at you in silent confusion...*"
        }
        
        isNPCThinking = false
    }
}
