//
//  HUDView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI

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

