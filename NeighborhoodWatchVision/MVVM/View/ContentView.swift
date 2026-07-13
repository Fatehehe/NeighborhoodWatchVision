//
//  ContentView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) var model
    
    var body: some View {
        Group {
            switch model.currentFlow {
            case .start:
                StartView()
            case .story:
                StoryView()
            case .playing:
                Text("Memasuki pos penjagaan...")
                    .font(.largeTitle)
                    .glassBackgroundEffect()
            case .result(let isWin):
                ResultView(isWin: isWin)
            }
        }
        .onAppear {
            model.loadGameData()
        }
        .animation(.default, value: model.currentFlow)
    }
}

// MARK: - Subviews untuk Tiap Flow
struct StartView: View {
    @Environment(AppModel.self) var model
    
    var body: some View {
        Image("game_title")
            .resizable()
            .scaledToFit()
//            .frame(width: 600, height: 400)
        
            .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
                FrameButton(title: "Start the Game") {
                    model.currentFlow = .story
                }
                .padding(.top, 20)
            }
    }
}

struct StoryView: View {
    @Environment(AppModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    let storyText = """
    Mas Yanto, ini si Marbella kurang ajar. Masa iya anomali dibiarin masuk ke kampung kita? Peja sampe harus nge-hack itu hape buat diatur frekuensinya, jadi kita bisa tangkap si anomali itu.
    
    Malam ini kamu yang jaga ya, saya pusing banget. Ini Kyai Sandy agak-agak requestnya ya--saya mesti jaga peti karung yang gatau lah apa itu isinya.
    
    Salam semangat.
    Tafa Kreasi, anak pak bos Brotowali Kreasi
    
    PS: Harusnya malam ini Handaru gak pulang, kayanya dia ke club. Katanya mau live toktok nyari duit, gatau deh. Mungkin cari tante
    """
    
    var body: some View {
        ZStack {
            Image("paper_container")
                .resizable()
                .scaledToFill()
            VStack {
                Text(storyText)
                    // .font(.custom("HandwritingFont", size: 22))
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
            }
            .padding(80)
        }
        .frame(width: 800, height: 600)
        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
            FrameButton(title: "Tutup") {
                Task {
                    model.currentFlow = .playing
                    await openImmersiveSpace(id: model.immersiveSpaceID)
                    dismissWindow()
                }
            }
            .padding(.top, 24)
        }
    }
}

struct ResultView: View {
    @Environment(AppModel.self) var model
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    let isWin: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Text(isWin ? "MISSION ACCOMPLISHED" : "GAME OVER")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(isWin ? .green : .red)
            
            Text(isWin ? "Kamu berhasil menjaga keamanan perumahan." : "Anomali berhasil menyusup.")
                .font(.title)
            
            HStack(spacing: 30) {
                FrameButton(title: "Retry") {
                    Task {
                        model.currentFlow = .playing
                        dismissWindow()
                    }
                }
                
                FrameButton(title: "Main Menu") {
                    model.currentFlow = .start
                    Task { await dismissImmersiveSpace() }
                }
            }
        }
        .padding(60)
        .glassBackgroundEffect()
    }
}

struct FrameButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    Image("button_frame")
                        .resizable()
                )
        }
        .buttonStyle(.plain)
    }
}
