//
//  StartFermentationSheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct StartFermentationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedDays = 7
    @State private var showingCustomInput = false
    @State private var customDays = ""
    @State private var customDaysSet = false
    @State private var showingAddNotes = false
    
    let onFermentationStarted: () -> Void
    
    private let dayOptions = [3, 5, 7, 10, 14]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: adaptiveVerticalSpacing) {
                    // Header
                    VStack(spacing: adaptiveHeaderSpacing) {
                        Text("Start Fermentation")
                            .font(.system(size: adaptiveTitleSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    // Brew Buddy Note Image
                    Image("brew_buddy_note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: adaptiveImageHeight)
                        .padding(.vertical, adaptiveImagePadding)
                    
                    // Subtitle moved under the image
                    Text("Choose how long to ferment your kombucha for")
                        .font(.system(size: adaptiveSubtitleSize, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    // Day selection grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: adaptiveGridSpacing), count: 2), spacing: adaptiveGridSpacing) {
                        ForEach(dayOptions, id: \.self) { days in
                            DayOptionCard(
                                days: days,
                                isSelected: selectedDays == days,
                                onTap: {
                                    selectedDays = days
                                }
                            )
                        }
                        
                        // Custom option
                        Button(action: {
                            showingCustomInput = true
                        }) {
                            VStack(spacing: adaptiveCustomSpacing) {
                                if customDaysSet {
                                    Text("\(selectedDays)")
                                        .font(.system(size: adaptiveCustomNumberSize, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("days")
                                        .font(.system(size: adaptiveCustomTextSize))
                                        .foregroundColor(.white.opacity(0.8))
                                } else {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: adaptiveCustomIconSize))
                                        .foregroundColor(.green)
                                    
                                    Text("Custom")
                                        .font(.system(size: adaptiveCustomTextSize))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: adaptiveCardHeight)
                            .background(customDaysSet ? Color.green : Color.gray.opacity(0.1))
                            .cornerRadius(adaptiveCardCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: adaptiveCardCornerRadius)
                                    .stroke(customDaysSet ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: adaptiveCardHeight)
                    }
                    
                    Spacer()
                    
                    // CTA button
                    CTAButton("Let's Go!", style: .primary, action: startFermentation)
                        .disabled(selectedDays <= 0)
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
                .padding(.vertical, adaptiveVerticalPadding)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)

        }
        .alert("Custom Duration", isPresented: $showingCustomInput) {
            TextField("Days", text: $customDays)
                .keyboardType(.numberPad)
            
            Button("Cancel", role: .cancel) { }
            Button("Set") {
                if let days = Int(customDays), days > 0 {
                    selectedDays = days
                    customDaysSet = true
                }
                customDays = ""
            }
        } message: {
            Text("Enter the number of days for fermentation")
        }
        .fullScreenCover(isPresented: $showingAddNotes) {
            AddNotesSheet(
                fermentationDays: selectedDays,
                onNotesCompleted: completeFermentationWithNotes
            )
        }
    }
    
    private func startFermentation() {
        showingAddNotes = true
    }
    
    private func completeFermentationWithNotes(scobyName: String?, teaType: TeaType?, sugar: String?, starterLiquidAmount: String?, activeNotes: String?) {
        fermentationManager.startFermentationWithDetails(
            days: selectedDays,
            scobyName: scobyName,
            teaType: teaType,
            sugar: sugar,
            starterLiquidAmount: starterLiquidAmount,
            activeNotes: activeNotes
        )
        
        onFermentationStarted()
        dismiss()
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveVerticalSpacing: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 14 : 10
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 28 : 24
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 28 : 20
    }
    
    private var adaptiveGridSpacing: CGFloat {
        isLargeDevice ? 18 : 14
    }
    
    private var adaptiveCustomSpacing: CGFloat {
        isLargeDevice ? 10 : 6
    }
    
    private var adaptiveCustomIconSize: CGFloat {
        isLargeDevice ? 30 : 26
    }
    
    private var adaptiveCustomTextSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveCustomNumberSize: CGFloat {
        isLargeDevice ? 30 : 26
    }
    
    private var adaptiveImageHeight: CGFloat {
        isLargeDevice ? 240 : 200
    }
    
    private var adaptiveImagePadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveCardHeight: CGFloat {
        isLargeDevice ? 100 : 80
    }
    
    private var adaptiveCardCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveStartButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveStartButtonHeight: CGFloat {
        isLargeDevice ? 52 : 44
    }
    
    private var adaptiveStartButtonCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
}

struct DayOptionCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let days: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: adaptiveSpacing) {
                Text("\(days)")
                    .font(.system(size: adaptiveNumberSize, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
                
                Text("days")
                    .font(.system(size: adaptiveTextSize))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: adaptiveHeight)
            .background(isSelected ? Color.green : Color.gray.opacity(0.1))
            .cornerRadius(adaptiveCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: adaptiveCornerRadius)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 10 : 6
    }
    
    private var adaptiveNumberSize: CGFloat {
        isLargeDevice ? 30 : 26
    }
    
    private var adaptiveTextSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveHeight: CGFloat {
        isLargeDevice ? 100 : 80
    }
    
    private var adaptiveCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
}

#Preview {
    StartFermentationSheet(onFermentationStarted: {})
        .environmentObject(FermentationManager())
} 
