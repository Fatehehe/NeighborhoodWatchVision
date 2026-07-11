//
//  VillageMapView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

struct VillageMapView: View {
    let houses: [HouseData]
    
    // Memisahkan rumah Blok A dan Blok B
    var blokA: [HouseData] {
        houses.filter { $0.houseID.hasPrefix("A") }.sorted { $0.houseID < $1.houseID }
    }
    
    var blokB: [HouseData] {
        houses.filter { $0.houseID.hasPrefix("B") }.sorted { $0.houseID < $1.houseID }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // BLOK A (Atas)
                    HStack(spacing: 20) {
                        ForEach(blokA) { house in
                            HouseNodeView(house: house)
                        }
                    }
                    
                    // JALAN UTAMA (Tengah)
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 80)
                        
                        // Garis putus-putus di tengah jalan
                        StreetDashedLine()
                            .stroke(style: StrokeStyle(lineWidth: 4, dash: [15, 10]))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: 1)
                        
                        Text("JALAN UTAMA")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary.opacity(0.5))
                    }
                    .padding(.vertical, 10)
                    
                    // BLOK B (Bawah)
                    HStack(spacing: 20) {
                        ForEach(blokB) { house in
                            HouseNodeView(house: house)
                        }
                    }
                }
                .padding(40)
            }
            .navigationTitle("Peta Desa")
        }
    }
}

// MARK: - Komponen UI: Kartu Rumah
struct HouseNodeView: View {
    let house: HouseData
    
    var body: some View {
        VStack(spacing: 8) {
            // Header: ID Rumah & Ikon Mobil
            HStack {
                Text(house.houseID)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                if house.hasParkedVehicle {
                    Image(systemName: "car.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }
            
            Divider()
            
            // Info Penghuni
            VStack {
                if let name = house.residentName {
                    Text(name)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                } else {
                    Text("KOSONG")
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
            }
            .frame(maxHeight: .infinity) // Agar tinggi konten seragam
        }
        .padding()
        .frame(width: 160, height: 140) // Ukuran statis agar rapi sebagai Map
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(house.residentID == nil ? Color.red : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// MARK: - Komponen UI: Bentuk Garis Jalan
struct StreetDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

