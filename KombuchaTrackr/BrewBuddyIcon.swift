//
//  BrewBuddyIcon.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct BrewBuddyIcon: View {
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.4),
                            Color.green.opacity(0.2),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 25,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
            
            // Main character body - more organic blob shape
            Ellipse()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green,
                            Color.green.opacity(0.9),
                            Color.green.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 75)
                .overlay(
                    // Subtle outline
                    Ellipse()
                        .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
                )
            
            // Eyes
            HStack(spacing: 18) {
                // Left eye
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 9, height: 9)
                    
                    // Eye highlight
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .offset(x: -2.5, y: -2.5)
                }
                
                // Right eye
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 9, height: 9)
                    
                    // Eye highlight
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .offset(x: -2.5, y: -2.5)
                }
            }
            .offset(y: -10)
            
            // Smile - more pronounced
            Path { path in
                path.move(to: CGPoint(x: -15, y: 10))
                path.addQuadCurve(
                    to: CGPoint(x: 15, y: 10),
                    control: CGPoint(x: 0, y: 20)
                )
            }
            .stroke(Color.black, lineWidth: 2.5)
            .frame(width: 30, height: 25)
        }
        .frame(width: 120, height: 120)
    }
}

#Preview {
    BrewBuddyIcon()
        .frame(width: 120, height: 120)
        .background(Color.gray.opacity(0.1))
} 