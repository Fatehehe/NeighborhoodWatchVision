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

public struct ResidentManifest: Codable, Identifiable {
    public var id: String { residentID }
    public let residentID: String
    public let trueName: String
    public let trueAddress: String
    public let occupation: String
    public let relation: String
    public let visualTraits: [String]
    public let personality: String
    public let secretLore: String
}

public struct EncounterData: Codable, Identifiable {
    public var id: String { encounterID }
    public let encounterID: String
    public let scenarioName: String
    public let spawnVisuals: [String]
    public let idCardData: IDCardData
    public let llmPromptContext: LLMPromptContext
}

public struct IDCardData: Codable {
    public let idAsset: String
    public let printedName: String
    public let gender: String
    public let birthDay: String
    public let printedAddress: String
    public let printedIDNumber: String
    public let expirationDate: String
}

public struct LLMPromptContext: Codable {
    public let roleType: RoleType
    public let characterName: String
    public let believedAddress: String
    public let believedOccupation: String
    public let objective: String
    public let spatialContext: String
    public let behavioralInstruction: String
}
