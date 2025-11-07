//
//  ConfettiView.swift
//  MemorySparks
//
//  Created by Krunal Mistry on 11/1/25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    private let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
    private let confettiCount = 50

    var body: some View {
        ZStack {
            ForEach(0..<confettiCount, id: \.self) { index in
                ConfettiPiece(color: colors[index % colors.count])
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: -400...400) : -100
                    )
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}
