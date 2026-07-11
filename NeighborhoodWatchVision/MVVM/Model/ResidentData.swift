//
//  ResidentData.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 07/07/26.
//

import Foundation

public enum RoleType: String, Codable {
    case resident
    case anomaly
}

struct ResidentManifest: Codable, Identifiable {
    var id: String { residentID }
    let residentID: String
    let trueName: String
    let trueAddress: String
    let occupation: String
    let relation: String
    let visualTraits: [String]
    let personality: String
    let secretLore: String
}

struct EncounterData: Codable, Identifiable {
    var id: String { encounterID }
    let encounterID: String
    let scenarioName: String
    let spawnVisuals: [String]
    let idCardData: IDCardData
    let llmPromptContext: LLMPromptContext
    let idImageURL: String
}

struct IDCardData: Codable {
    let printedName: String
    let printedAddress: String
    let printedIDNumber: String
    let expirationDate: String
}

struct LLMPromptContext: Codable {
    let roleType: RoleType
    let characterName: String
    let believedAddress: String
    let believedOccupation: String
    let objective: String
    let spatialContext: String
    let behavioralInstruction: String
}
