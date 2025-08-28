//
//  ContentView.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showingStartSheet = false
    @State private var showingHistorySheet = false
    @State private var editingFermentation: Fermentation?

    var body: some View {
        NavigationView {
            ZStack {
                // Background - ensure it fills the entire screen
                Color.white
                    .ignoresSafeArea(.all)

                if fermentationManager.hasCompletedUnratedFermentation {
                    // Show completion screen for rating and notes
                    CompletionView()
                } else if fermentationManager.hasActiveFermentations {
                    // Multiple active fermentations view
                    ActiveBatchesView(
                        fermentations: fermentationManager.activeFermentations,
                        onEdit: { fermentation in
                            editingFermentation = fermentation
                        },
                        onStartNew: { showingStartSheet = true }
                    )
                } else {
                    // Initial screen with active batches list
                    StarterScreenView(
                        onStartNew: { showingStartSheet = true },
                        onViewHistory: { showingHistorySheet = true }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showingStartSheet) {
            StartFermentationSheet(onFermentationStarted: {
                // After starting fermentation, dismiss the sheet
                // ContentView will automatically show active timers
            })
        }
        .fullScreenCover(item: $editingFermentation) { fermentation in
            EditFermentationSheet(fermentationID: fermentation.id)
                .environmentObject(fermentationManager)
        }
        .fullScreenCover(isPresented: $showingHistorySheet) {
            HistorySheet()
        }
    }
}

struct StarterScreenView: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let onStartNew: () -> Void
    let onViewHistory: () -> Void
    
    var body: some View {
        VStack(spacing: adaptiveSpacing) {
            Spacer()
            
            // Full Image Header
            Image("brew_buddy_full")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: adaptiveImageWidth, maxHeight: adaptiveImageHeight)
                .padding(.top, adaptiveTopPadding)

            Text("Brew Buddy")
                .font(.system(size: adaptiveTitleSize, weight: .bold))
                .foregroundColor(.black)

            Text("Let's track your brew together!")
                .font(.system(size: adaptiveSubtitleSize))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, adaptiveHorizontalPadding)

            // CTA Button - Always show "Start New Batch"
            Button(action: onStartNew) {
                Text("Start New Batch")
                    .font(.system(size: adaptiveButtonFontSize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, adaptiveButtonPadding)
                    .background(Color.green)
                    .cornerRadius(adaptiveCornerRadius)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, adaptiveHorizontalPadding)

            // History button
            Button(action: onViewHistory) {
                HStack(spacing: adaptiveIconSpacing) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: adaptiveIconSize))
                    Text("View History")
                        .font(.system(size: adaptiveSecondaryButtonFontSize))
                }
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding(.vertical, adaptiveSecondaryButtonVerticalPadding)
                .background(Color.green.opacity(0.1))
                .cornerRadius(adaptiveSecondaryCornerRadius)
            }
            .padding(.horizontal, adaptiveHorizontalPadding)

            Spacer(minLength: adaptiveMiddleSpacerMinLength)

            // Active batches section
            if fermentationManager.hasActiveFermentations {
                VStack(spacing: adaptiveActiveBatchesSpacing) {
                    Text("Active Batches")
                        .font(.system(size: adaptiveActiveBatchesTitleSize, weight: .semibold))
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: adaptiveBatchCardSpacing) {
                            ForEach(fermentationManager.activeFermentations) { fermentation in
                                ActiveBatchCard(fermentation: fermentation)
                            }
                        }
                        .padding(.horizontal, adaptiveHorizontalPadding)
                    }
                }
                .padding(.vertical, adaptiveActiveBatchesVerticalPadding)
                
                // Separator
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, adaptiveHorizontalPadding)
                    .padding(.vertical, adaptiveStarterSeparatorPadding)
            }


            Spacer(minLength: adaptiveBottomSpacerMinLength)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 22 : 18
    }
    
    private var adaptiveImageWidth: CGFloat {
        isLargeDevice ? 280 : 220
    }
    
    private var adaptiveImageHeight: CGFloat {
        isLargeDevice ? 200 : 160
    }
    
    private var adaptiveTopPadding: CGFloat {
        isLargeDevice ? 24 : 12
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 38 : 30
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 20 : 17
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 35 : 25
    }
    
    private var adaptiveActiveBatchesSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveActiveBatchesTitleSize: CGFloat {
        isLargeDevice ? 22 : 18
    }
    
    private var adaptiveActiveBatchesVerticalPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveBatchCardSpacing: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveMiddleSpacerMinLength: CGFloat {
        isLargeDevice ? 6 : 3
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 18 : 14
    }
    
    private var adaptiveButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveButtonMaxWidth: CGFloat? {
        isLargeDevice ? 350 : 300
    }
    
    private var adaptiveButtonPadding: CGFloat {
        isLargeDevice ? 13 : 11
    }
    
    private var adaptiveCornerRadius: CGFloat {
        isLargeDevice ? 14 : 10
    }
    
    private var adaptiveIconSpacing: CGFloat {
        isLargeDevice ? 8 : 5
    }
    
    private var adaptiveIconSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveSecondaryButtonFontSize: CGFloat {
        isLargeDevice ? 15 : 13
    }
    
    private var adaptiveSecondaryButtonPadding: CGFloat {
        isLargeDevice ? 18 : 14
    }
    
    private var adaptiveSecondaryButtonVerticalPadding: CGFloat {
        isLargeDevice ? 10 : 6
    }
    
    private var adaptiveSecondaryCornerRadius: CGFloat {
        isLargeDevice ? 22 : 18
    }
    
    private var adaptiveBottomSpacerMinLength: CGFloat {
        isLargeDevice ? 16 : 8
    }
    
    private var adaptiveStarterSeparatorPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptivePromptTextSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptivePromptBottomPadding: CGFloat {
        isLargeDevice ? 8 : 6
    }
}

struct ActiveBatchCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let fermentation: Fermentation
    
    var body: some View {
        VStack(spacing: adaptiveSpacing) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: adaptiveCircleStrokeWidth)
                    .frame(width: adaptiveCircleSize, height: adaptiveCircleSize)
                
                Circle()
                    .trim(from: 0, to: fermentation.progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: adaptiveCircleStrokeWidth, lineCap: .round)
                    )
                    .frame(width: adaptiveCircleSize, height: adaptiveCircleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: fermentation.progress)
            }
            
            // Batch name
            Text(fermentation.name)
                .font(.system(size: adaptiveNameFontSize, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            // Time remaining
            Text(timeString(from: fermentation.timeRemaining))
                .font(.system(size: adaptiveTimeFontSize))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: adaptiveCardWidth)
        .padding(adaptiveCardPadding)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(adaptiveCardCornerRadius)
        
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveCircleSize: CGFloat {
        isLargeDevice ? 60 : 50
    }
    
    private var adaptiveCircleStrokeWidth: CGFloat {
        isLargeDevice ? 4 : 3
    }
    
    private var adaptiveNameFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveTimeFontSize: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveCardWidth: CGFloat {
        isLargeDevice ? 120 : 100
    }
    
    private var adaptiveCardPadding: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveCardCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval) % 86400 / 3600
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = Int(timeInterval) % 3600 / 60
            return "\(minutes)m"
        }
    }
}

struct ActiveBatchesView: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedFermentation: Fermentation?
    @State private var showingHistory = false
    let fermentations: [Fermentation]
    let onEdit: (Fermentation) -> Void
    let onStartNew: () -> Void
    
    var body: some View {
        Group {
            if let selectedFermentation = selectedFermentation {
                // Detailed fermentation view
                DetailedFermentationView(
                    fermentation: selectedFermentation,
                    onBack: { self.selectedFermentation = nil },
                    onEdit: { onEdit(selectedFermentation) }
                )
            } else {
                // List view
                ScrollView {
                    VStack(spacing: adaptiveSpacing) {
                        if fermentations.count == 1 {
                            // Single fermentation - show only the card with action buttons
                            ForEach(fermentations) { fermentation in
                                ActiveFermentationCard(
                                    fermentation: fermentation,
                                    onEdit: { onEdit(fermentation) },
                                    onStartNew: onStartNew
                                )
                            }
                            .padding(.horizontal, adaptiveHorizontalPadding)
                            .padding(.bottom, adaptiveBatchBottomPadding)
                        } else {
                            // Header for multiple fermentations
                            VStack(spacing: adaptiveHeaderSpacing) {
                                Text("Active Batches")
                                    .font(.system(size: adaptiveTitleSize, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("\(fermentations.count) batches brewing")
                                    .font(.system(size: adaptiveSubtitleSize))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, adaptiveTopPadding)
                            
                            // Multiple fermentations - show compact line layout
                            VStack(spacing: adaptiveMultipleBatchSpacing) {
                                ForEach(fermentations) { fermentation in
                                                                    CompactFermentationRow(
                                    fermentation: fermentation,
                                    onSelect: { 
                                        selectedFermentation = fermentation
                                    }
                                )
                                }
                            }
                            .padding(.horizontal, adaptiveHorizontalPadding)
                            .padding(.bottom, adaptiveMultipleBatchBottomPadding)
                            
                            Spacer(minLength: adaptiveMultipleBatchSpacerMinLength)
                            
                            // CTA buttons at bottom for multiple batches
                            VStack(spacing: adaptiveMultipleBatchButtonSpacing) {
                                Button(action: onStartNew) {
                                    HStack(spacing: adaptiveMultipleBatchButtonIconSpacing) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: adaptiveMultipleBatchButtonIconSize))
                                        Text("Start New Batch")
                                            .font(.system(size: adaptiveMultipleBatchButtonFontSize, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, adaptiveMultipleBatchButtonPadding)
                                    .background(Color.green)
                                    .cornerRadius(adaptiveMultipleBatchButtonCornerRadius)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                }
                                
                                Button(action: {
                                    showingHistory = true
                                }) {
                                    HStack(spacing: adaptiveMultipleBatchButtonIconSpacing) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: adaptiveMultipleBatchButtonIconSize))
                                        Text("View History")
                                            .font(.system(size: adaptiveMultipleBatchButtonFontSize, weight: .semibold))
                                    }
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, adaptiveMultipleBatchButtonPadding)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(adaptiveMultipleBatchButtonCornerRadius)
                                }
                            }
                            .padding(.horizontal, adaptiveHorizontalPadding)
                            .padding(.bottom, adaptiveBottomPadding)
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .fullScreenCover(isPresented: $showingHistory) {
            HistorySheet()
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveTopPadding: CGFloat {
        isLargeDevice ? 24 : 16
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 32 : 26
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 18 : 15
    }
    
    private var adaptiveBatchSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveBatchBottomPadding: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveSeparatorPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveNewBatchSectionSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveNewBatchPromptSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveNewBatchButtonIconSpacing: CGFloat {
        isLargeDevice ? 10 : 6
    }
    
    private var adaptiveNewBatchButtonIconSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveNewBatchButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveNewBatchButtonMaxWidth: CGFloat? {
        isLargeDevice ? 350 : nil
    }
    
    private var adaptiveNewBatchButtonPadding: CGFloat {
        isLargeDevice ? 13 : 11
    }
    
    private var adaptiveNewBatchButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveNewBatchButtonHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveBottomPadding: CGFloat {
        isLargeDevice ? 24 : 16
    }
    
    // Multiple batch layout properties
    private var adaptiveMultipleBatchSpacing: CGFloat {
        isLargeDevice ? 10 : 8
    }
    
    private var adaptiveMultipleBatchBottomPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveMultipleBatchSpacerMinLength: CGFloat {
        isLargeDevice ? 24 : 16
    }
    
    private var adaptiveMultipleBatchButtonSpacing: CGFloat {
        isLargeDevice ? 13 : 10
    }
    
    private var adaptiveMultipleBatchButtonIconSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveMultipleBatchButtonIconSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveMultipleBatchButtonFontSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveMultipleBatchButtonPadding: CGFloat {
        isLargeDevice ? 11 : 10
    }
    
    private var adaptiveMultipleBatchButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
}

struct ActiveFermentationCard: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showingFinishConfirmation = false
    @State private var showingHistory = false
    let fermentation: Fermentation
    let onEdit: () -> Void
    let onStartNew: () -> Void
    
    var body: some View {
        VStack(spacing: adaptiveSpacing) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: adaptiveCircleStrokeWidth)
                    .frame(width: adaptiveCircleSize, height: adaptiveCircleSize)
                
                Circle()
                    .trim(from: 0, to: fermentation.progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: adaptiveCircleStrokeWidth, lineCap: .round)
                    )
                    .frame(width: adaptiveCircleSize, height: adaptiveCircleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: fermentation.progress)
                
                // Time display
                VStack(spacing: 4) {
                    Text(timeString(from: fermentation.timeRemaining))
                        .font(.system(size: adaptiveTimeFontSize, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("remaining")
                        .font(.system(size: adaptiveTimeSubtitleSize))
                        .foregroundColor(.black)
                }
            }
            
            // Batch name
            Text("\(fermentation.name) is brewing...")
                .font(.system(size: adaptiveNameFontSize, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            // Custom swiggly path animation (replacing Lottie)
            SwigglyPathAnimation()
                .frame(width: adaptiveLoadingBarWidth, height: adaptiveLoadingBarHeight)
                .padding(.vertical, 8)
            
            // Edit duration button (pencil icon) - BELOW ANIMATION
            Button(action: onEdit) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                    Text("Edit Duration")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            }
            
            // Info cards
            VStack(spacing: adaptiveInfoCardSpacing) {
                InfoCard(
                    icon: "calendar",
                    title: "Started",
                    value: fermentation.startDate.formatted(date: .abbreviated, time: .omitted)
                )
                
                InfoCard(
                    icon: "clock",
                    title: "Duration",
                    value: "\(fermentation.durationDays) days"
                )
                
                InfoCard(
                    icon: "target",
                    title: "Ready by",
                    value: fermentation.endDate.formatted(date: .abbreviated, time: .omitted)
                )
            }
            
            // Action buttons
            VStack(spacing: adaptiveActionButtonSpacing) {
                Button(action: onStartNew) {
                    HStack(spacing: adaptiveButtonIconSpacing) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: adaptiveButtonIconSize))
                        Text("Start Second Batch")
                            .font(.system(size: adaptiveActionButtonFontSize, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, adaptiveActionButtonPadding)
                    .background(Color.blue)
                    .cornerRadius(adaptiveActionButtonCornerRadius)
                }
                
                Button(action: {
                    showingFinishConfirmation = true
                }) {
                    HStack(spacing: adaptiveButtonIconSpacing) {
                        Image(systemName: "stop.circle")
                            .font(.system(size: adaptiveButtonIconSize))
                        Text("End Fermentation")
                            .font(.system(size: adaptiveActionButtonFontSize, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, adaptiveActionButtonPadding)
                    .background(Color.red)
                    .cornerRadius(adaptiveActionButtonCornerRadius)
                }
                
                // History button below End Fermentation
                Button(action: {
                    showingHistory = true
                }) {
                    HStack(spacing: adaptiveButtonIconSpacing) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: adaptiveButtonIconSize))
                        Text("History")
                            .font(.system(size: adaptiveActionButtonFontSize, weight: .semibold))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, adaptiveActionButtonPadding)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(adaptiveActionButtonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: adaptiveActionButtonCornerRadius)
                            .stroke(Color.green, lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, adaptiveHorizontalPadding)
        .padding(.vertical, adaptiveVerticalPadding)
        .confirmationDialog(
            "Are you sure you want to finish \(fermentation.name) early?",
            isPresented: $showingFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button("Finish Early", role: .destructive) {
                fermentationManager.finishFermentationEarly(id: fermentation.id)
            }
            Button("Cancel", role: .cancel) { }
        }
        .fullScreenCover(isPresented: $showingHistory) {
            HistorySheet()
        }
        
        // Fermentation Details Section (moved to bottom after buttons)
        if hasFermentationDetails {
            VStack(spacing: adaptiveDetailsSpacing) {
                Text("Fermentation Details")
                    .font(.system(size: adaptiveDetailsTitleSize, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(spacing: adaptiveDetailRowSpacing) {
                    if let scobyName = fermentation.scobyName, !scobyName.isEmpty {
                        DetailRow(icon: "leaf.fill", iconColor: .green, text: "SCOBY: \(scobyName)")
                    }
                    
                    if let teaType = fermentation.teaType {
                        DetailRow(icon: "cup.and.saucer.fill", iconColor: .brown, text: "Tea: \(teaType.displayName)")
                    }
                    
                    if let sugar = fermentation.sugar, !sugar.isEmpty {
                        DetailRow(icon: "drop.fill", iconColor: .yellow, text: "Sugar: \(sugar)")
                    }
                    
                    if let starterLiquid = fermentation.starterLiquidAmount, !starterLiquid.isEmpty {
                        DetailRow(icon: "drop.degreesign.fill", iconColor: .blue, text: "Starter: \(starterLiquid)")
                    }
                    
                    if let activeNotes = fermentation.activeNotes, !activeNotes.isEmpty {
                        DetailRow(icon: "note.text", iconColor: .purple, text: "Notes: \(activeNotes)")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(adaptiveDetailsCornerRadius)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasFermentationDetails: Bool {
        fermentation.scobyName != nil || 
        fermentation.teaType != nil || 
        fermentation.sugar != nil || 
        fermentation.starterLiquidAmount != nil || 
        fermentation.activeNotes != nil
    }
    
    // MARK: - Helper Methods
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval) % 86400 / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveCircleSize: CGFloat {
        isLargeDevice ? 200 : 160
    }
    
    private var adaptiveCircleStrokeWidth: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveTimeFontSize: CGFloat {
        isLargeDevice ? 24 : 20
    }
    
    private var adaptiveTimeSubtitleSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveNameFontSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveInfoCardSpacing: CGFloat {
        isLargeDevice ? 8 : 5
    }
    
    private var adaptiveActionButtonSpacing: CGFloat {
        isLargeDevice ? 11 : 8
    }
    
    private var adaptiveButtonIconSpacing: CGFloat {
        isLargeDevice ? 6 : 5
    }
    
    private var adaptiveButtonIconSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveActionButtonFontSize: CGFloat {
        isLargeDevice ? 16 : 15
    }
    
    private var adaptiveActionButtonPadding: CGFloat {
        isLargeDevice ? 13 : 11
    }
    
    private var adaptiveActionButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveDetailsTitleSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveDetailRowSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveDetailsCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveLoadingBarWidth: CGFloat {
        isLargeDevice ? 320 : 280
    }
    
    private var adaptiveLoadingBarHeight: CGFloat {
        isLargeDevice ? 32 : 28
    }
    
}

// MARK: - DetailRow View
struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// Keep existing CompletionView and InfoCard for now
struct CompletionView: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showingRatingSheet = false
    @State private var showingStartSheet = false
    
    private var completedFermentation: Fermentation? {
        fermentationManager.completedUnratedFermentation
    }
    
    var body: some View {
        VStack(spacing: adaptiveSpacing) {
            // Celebration animation
            ZStack {
                // Smaller, lighter, organic gradient background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.25),
                                Color.yellow.opacity(0.2),
                                Color.green.opacity(0.15),
                                Color.green.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: adaptiveCelebrationSize * 1.2, height: adaptiveCelebrationSize * 1.2)
                    .blur(radius: 8)
                    .overlay(
                        // Add irregular, messy texture overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.15),
                                        Color.green.opacity(0.12),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: adaptiveCelebrationSize * 1.1, height: adaptiveCelebrationSize * 1.0)
                            .blur(radius: 6)
                            .offset(x: 8, y: -6)
                    )
                    .overlay(
                        // Add another irregular blob for messiness
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.1),
                                        Color.green.opacity(0.08),
                                        Color.clear
                                    ]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                            .frame(width: adaptiveCelebrationSize * 0.9, height: adaptiveCelebrationSize * 1.0)
                            .blur(radius: 7)
                            .offset(x: -12, y: 8)
                    )
                
                Image("brew_buddy_cheers")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: adaptiveImageWidth, maxHeight: adaptiveImageHeight)
            }
            .padding(.top, adaptiveImageTopPadding)
            
            VStack(spacing: adaptiveTextSpacing) {
                Text("Fermentation finale!")
                    .font(.system(size: adaptiveTitleSize, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Pour, sip, and enjoy your bubbly brew ✨")
                    .font(.system(size: adaptiveSubtitleSize))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, adaptiveHorizontalPadding)
            }
            
            VStack(spacing: adaptiveButtonSpacing) {
                Button(action: {
                    showingRatingSheet = true
                }) {
                    HStack {
                        Text("Rate & Add Notes")
                            .font(.system(size: adaptiveButtonFontSize, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: adaptiveButtonMaxWidth)
                    .padding(.vertical, adaptiveButtonPadding)
                    .background(Color.orange)
                    .cornerRadius(adaptiveButtonCornerRadius)
                }
                
                Button(action: {
                    // Show the start fermentation sheet
                    showingStartSheet = true
                }) {
                    Text("Start New Batch")
                        .font(.system(size: adaptiveButtonFontSize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: adaptiveButtonMaxWidth)
                        .padding(.vertical, adaptiveButtonPadding)
                        .background(Color.green)
                        .cornerRadius(adaptiveButtonCornerRadius)
                }
                
                Button(action: {
                    // Go back to active batches view
                    fermentationManager.completeRatingAndNotes()
                }) {
                    Text("Back to Active Batches")
                        .font(.system(size: adaptiveButtonFontSize, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(maxWidth: adaptiveButtonMaxWidth)
                        .padding(.vertical, adaptiveButtonPadding)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(adaptiveButtonCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: adaptiveButtonCornerRadius)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, adaptiveHorizontalPadding)
        }
        .padding(.vertical, adaptiveVerticalPadding)
        .background(Color.white)
        .fullScreenCover(isPresented: $showingRatingSheet) {
            RatingAndNotesSheet()
        }
        .fullScreenCover(isPresented: $showingStartSheet) {
            StartFermentationSheet(onFermentationStarted: {
                // After starting fermentation, dismiss the completion view
                // and let the ContentView automatically show the active timers
                fermentationManager.completeRatingAndNotes()
            })
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveCelebrationSize: CGFloat {
        isLargeDevice ? 260 : 220
    }
    
    private var adaptiveImageWidth: CGFloat {
        isLargeDevice ? 240 : 200
    }
    
    private var adaptiveImageHeight: CGFloat {
        isLargeDevice ? 180 : 140
    }
    
    private var adaptiveImageTopPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveTextSpacing: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 32 : 26
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 18 : 15
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 35 : 25
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 11 : 8
    }
    
    private var adaptiveButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveButtonMaxWidth: CGFloat? {
        isLargeDevice ? 400 : nil
    }
    
    private var adaptiveButtonPadding: CGFloat {
        isLargeDevice ? 13 : 11
    }
    
    private var adaptiveButtonCornerRadius: CGFloat {
        isLargeDevice ? 14 : 10
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 12 : 10
    }
}

struct CompactFermentationRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let fermentation: Fermentation
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: adaptiveRowSpacing) {
            // Small progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: adaptiveSmallCircleStrokeWidth)
                    .frame(width: adaptiveSmallCircleSize, height: adaptiveSmallCircleSize)
                
                Circle()
                    .trim(from: 0, to: fermentation.progress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: adaptiveSmallCircleStrokeWidth, lineCap: .round)
                    )
                    .frame(width: adaptiveSmallCircleSize, height: adaptiveSmallCircleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: fermentation.progress)
            }
            
            // Batch info
            VStack(alignment: .leading, spacing: adaptiveRowInfoSpacing) {
                Text(fermentation.name)
                    .font(.system(size: adaptiveRowNameFontSize, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(timeString(from: fermentation.timeRemaining))
                    .font(.system(size: adaptiveRowTimeFontSize))
                    .foregroundColor(.secondary)
                
                // Custom swiggly path animation (smaller size for compact view)
                SwigglyPathAnimation()
                    .frame(width: adaptiveCompactLoadingBarWidth, height: adaptiveCompactLoadingBarHeight)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Select button
            Button(action: onSelect) {
                Image(systemName: "chevron.right")
                    .font(.system(size: adaptiveRowEditIconSize))
                    .foregroundColor(.green)
                    .padding(adaptiveRowEditPadding)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, adaptiveRowHorizontalPadding)
        .padding(.vertical, adaptiveRowVerticalPadding)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(adaptiveRowCornerRadius)
        
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveRowSpacing: CGFloat {
        isLargeDevice ? 15 : 12
    }
    
    private var adaptiveSmallCircleSize: CGFloat {
        isLargeDevice ? 40 : 32
    }
    
    private var adaptiveSmallCircleStrokeWidth: CGFloat {
        isLargeDevice ? 3 : 2.5
    }
    
    private var adaptiveRowInfoSpacing: CGFloat {
        isLargeDevice ? 4 : 3
    }
    
    private var adaptiveRowNameFontSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveRowTimeFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveRowEditIconSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveRowEditPadding: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveRowHorizontalPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveRowVerticalPadding: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveRowCornerRadius: CGFloat {
        isLargeDevice ? 10 : 8
    }
    
    // Loading animation properties for compact view
    private var adaptiveCompactLoadingBarWidth: CGFloat {
        isLargeDevice ? 120 : 100
    }
    
    private var adaptiveCompactLoadingBarHeight: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval) % 86400 / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if days > 365 {
            let years = days / 365
            let remainingDays = days % 365
            return remainingDays > 0 ? "\(years)y \(remainingDays)d" : "\(years)y"
        } else if days > 30 {
            let months = days / 30
            let remainingDays = days % 30
            return remainingDays > 0 ? "\(months)mo \(remainingDays)d" : "\(months)mo"
        } else if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct DetailedFermentationView: View {
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var showingFinishConfirmation = false
    let fermentation: Fermentation
    let onBack: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button and edit button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: adaptiveBackButtonSpacing) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: adaptiveBackButtonIconSize, weight: .semibold))
                        Text("Back to List")
                            .font(.system(size: adaptiveBackButtonTextSize, weight: .medium))
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                // Edit button (small pencil icon) - TOP OF PAGE
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, adaptiveHeaderHorizontalPadding)
            .padding(.vertical, adaptiveHeaderVerticalPadding)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            ScrollView {
                VStack(spacing: adaptiveContentSpacing) {
                    // Progress circle with live countdown
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: adaptiveLargeCircleStrokeWidth)
                            .frame(width: adaptiveLargeCircleSize, height: adaptiveLargeCircleSize)
                        
                        Circle()
                            .trim(from: 0, to: fermentation.progress)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: adaptiveLargeCircleStrokeWidth, lineCap: .round)
                            )
                            .frame(width: adaptiveLargeCircleSize, height: adaptiveLargeCircleSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: fermentation.progress)
                        
                        // Time display
                        VStack(spacing: adaptiveTimeDisplaySpacing) {
                            Text(timeString(from: fermentation.timeRemaining))
                                .font(.system(size: adaptiveTimeDisplayFontSize, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("remaining")
                                .font(.system(size: adaptiveTimeDisplaySubtitleSize))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, adaptiveCircleTopPadding)
                    
                    // Batch name
                    Text(fermentation.name)
                        .font(.system(size: adaptiveBatchNameFontSize, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    // Custom swiggly path animation
                    SwigglyPathAnimation()
                        .frame(width: adaptiveLoadingBarWidth, height: adaptiveLoadingBarHeight)
                        .padding(.vertical, 8)
                    
                    // Info cards
                    VStack(spacing: adaptiveInfoCardSpacing) {
                        InfoCard(
                            icon: "calendar",
                            title: "Started",
                            value: fermentation.startDate.formatted(date: .abbreviated, time: .omitted)
                        )
                        
                        InfoCard(
                            icon: "clock",
                            title: "Duration",
                            value: "\(fermentation.durationDays) days"
                        )
                        
                        InfoCard(
                            icon: "target",
                            title: "Ready by",
                            value: fermentation.endDate.formatted(date: .abbreviated, time: .omitted)
                        )
                    }
                    
                    // Single action button
                    Button(action: {
                        showingFinishConfirmation = true
                    }) {
                        HStack(spacing: adaptiveActionButtonIconSpacing) {
                            Image(systemName: "stop.circle")
                                .font(.system(size: adaptiveActionButtonIconSize))
                            Text("End Fermentation")
                                .font(.system(size: adaptiveActionButtonFontSize, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, adaptiveActionButtonPadding)
                        .background(Color.red)
                        .cornerRadius(adaptiveActionButtonCornerRadius)
                    }
                    .padding(.horizontal, adaptiveActionButtonHorizontalPadding)
                    .padding(.bottom, adaptiveActionButtonBottomPadding)
                }
                .padding(.horizontal, adaptiveContentHorizontalPadding)
            }
        }
        .background(Color.white)
        .confirmationDialog(
            "Are you sure you want to finish \(fermentation.name) early?",
            isPresented: $showingFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button("Finish Early", role: .destructive) {
                fermentationManager.finishFermentationEarly(id: fermentation.id)
                onBack() // Go back to list after finishing
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveBackButtonSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveBackButtonIconSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveBackButtonTextSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveHeaderTitleSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveHeaderHorizontalPadding: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveHeaderVerticalPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveContentSpacing: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveLargeCircleSize: CGFloat {
        isLargeDevice ? 220 : 180
    }
    
    private var adaptiveLargeCircleStrokeWidth: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveCircleTopPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveTimeDisplaySpacing: CGFloat {
        isLargeDevice ? 6 : 4
    }
    
    private var adaptiveTimeDisplayFontSize: CGFloat {
        isLargeDevice ? 28 : 24
    }
    
    private var adaptiveTimeDisplaySubtitleSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveBatchNameFontSize: CGFloat {
        isLargeDevice ? 22 : 20
    }
    
    private var adaptiveInfoCardSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveActionButtonSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveActionButtonIconSpacing: CGFloat {
        isLargeDevice ? 10 : 8
    }
    
    private var adaptiveActionButtonIconSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveActionButtonFontSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveActionButtonPadding: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveActionButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveActionButtonHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveActionButtonBottomPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveContentHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    // Loading animation properties
    private var adaptiveLoadingBarWidth: CGFloat {
        isLargeDevice ? 320 : 280
    }
    
    private var adaptiveLoadingBarHeight: CGFloat {
        isLargeDevice ? 32 : 28
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = Int(timeInterval) % 86400 / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if days > 365 {
            let years = days / 365
            let remainingDays = days % 365
            return remainingDays > 0 ? "\(years)y \(remainingDays)d" : "\(years)y"
        } else if days > 30 {
            let months = days / 30
            let remainingDays = days % 30
            return remainingDays > 0 ? "\(months)mo \(remainingDays)d" : "\(months)mo"
        } else if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct InfoCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: adaptiveIconSpacing) {
            Image(systemName: icon)
                .font(.system(size: adaptiveIconSize))
                .foregroundColor(.green)
                .frame(width: adaptiveIconFrameSize)
            
            VStack(alignment: .leading, spacing: adaptiveTextSpacing) {
                Text(title)
                    .font(.system(size: adaptiveTitleSize))
                    .foregroundColor(.black)
                Text(value)
                    .font(.system(size: adaptiveValueSize, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(adaptivePadding)
        .background(Color.gray.opacity(0.03))
        .cornerRadius(adaptiveCornerRadius)
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }
    
    private var adaptiveIconSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveIconSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveIconFrameSize: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveTextSpacing: CGFloat {
        isLargeDevice ? 3 : 2
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 12 : 11
    }
    
    private var adaptiveValueSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptivePadding: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
}

#Preview {
    ContentView()
        .environmentObject(FermentationManager())
}
