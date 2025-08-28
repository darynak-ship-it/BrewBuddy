//
//  RatingAndNotesSheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct RatingAndNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedRating = 0
    @State private var notes = ""
    @State private var showingHistory = false
    
    // Use the completed fermentation that needs rating
    private var currentFermentation: Fermentation? {
        fermentationManager.completedUnratedFermentation
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                RatingAndNotesTab(
                    selectedRating: $selectedRating,
                    notes: $notes,
                    dismiss: dismiss,
                    showingHistory: $showingHistory,
                    currentFermentation: currentFermentation
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveRatingAndNotes()
                    }
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .onAppear {
            if let fermentation = currentFermentation {
                selectedRating = fermentation.rating ?? 0
                notes = fermentation.notes ?? ""
            }
        }
        .fullScreenCover(isPresented: $showingHistory) {
            HistoryView()
        }
    }
    
    private func saveRatingAndNotes() {
        if let fermentation = currentFermentation {
            // Create updated fermentation with new rating and notes
            let updatedFermentation = Fermentation(
                id: fermentation.id,
                name: fermentation.name,
                startDate: fermentation.startDate,
                endDate: fermentation.endDate,
                durationDays: fermentation.durationDays,
                rating: selectedRating,
                notes: notes,
                scobyName: fermentation.scobyName,
                teaType: fermentation.teaType,
                sugar: fermentation.sugar,
                starterLiquidAmount: fermentation.starterLiquidAmount,
                activeNotes: fermentation.activeNotes
            )
            
            // Update the completed fermentation in the manager
            fermentationManager.completedUnratedFermentation = updatedFermentation
            
            // Complete the rating and notes process
            fermentationManager.completeRatingAndNotes()
            
            // Dismiss the sheet
            dismiss()
        }
    }
}

struct RatingAndNotesTab: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Binding var selectedRating: Int
    @Binding var notes: String
    let dismiss: DismissAction
    @Binding var showingHistory: Bool
    let currentFermentation: Fermentation?
    
    var body: some View {
        VStack(spacing: adaptiveVerticalSpacing) {
            // Header
            VStack(spacing: adaptiveHeaderSpacing) {
                Image("brew_buddy_note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("How was your kombucha?")
                    .font(.system(size: adaptiveTitleSize, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Rate your fermentation and add notes")
                    .font(.system(size: adaptiveSubtitleSize))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Rating section
            VStack(spacing: adaptiveRatingSpacing) {
                Text("Rating")
                    .font(.system(size: adaptiveRatingTitleSize, weight: .semibold))
                    .foregroundColor(.black)
                
                HStack(spacing: adaptiveStarSpacing) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            selectedRating = star
                        }) {
                            Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: adaptiveStarSize))
                                .foregroundColor(star <= selectedRating ? .yellow : .gray)
                        }
                    }
                }
            }
            
            // Notes section
            VStack(alignment: .leading, spacing: adaptiveNotesSpacing) {
                Text("Notes")
                    .font(.system(size: adaptiveNotesTitleSize, weight: .semibold))
                    .foregroundColor(.black)
                
                TextField("Add your notes here...", text: $notes)
                    .font(.system(size: adaptiveTextFieldSize))
                    .padding(adaptiveTextFieldPadding)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(adaptiveTextFieldCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity)
            
            // Fermentation Details Section
            if hasFermentationDetails {
                VStack(alignment: .leading, spacing: adaptiveDetailsSpacing) {
                    Text("Fermentation Details")
                        .font(.system(size: adaptiveDetailsTitleSize, weight: .semibold))
                        .foregroundColor(.black)
                    
                    VStack(spacing: adaptiveDetailRowSpacing) {
                        if let scobyName = currentFermentation?.scobyName, !scobyName.isEmpty {
                            DetailRow(icon: "leaf.fill", iconColor: .green, text: "SCOBY: \(scobyName)")
                        }
                        
                        if let teaType = currentFermentation?.teaType {
                            DetailRow(icon: "cup.and.saucer.fill", iconColor: .brown, text: "Tea: \(teaType.displayName)")
                        }
                        
                        if let sugar = currentFermentation?.sugar, !sugar.isEmpty {
                            DetailRow(icon: "drop.fill", iconColor: .yellow, text: "Sugar: \(sugar)")
                        }
                        
                        if let starterLiquid = currentFermentation?.starterLiquidAmount, !starterLiquid.isEmpty {
                            DetailRow(icon: "drop.degreesign.fill", iconColor: .blue, text: "Starter: \(starterLiquid)")
                        }
                        
                        if let activeNotes = currentFermentation?.activeNotes, !activeNotes.isEmpty {
                            DetailRow(icon: "note.text", iconColor: .purple, text: "Notes: \(activeNotes)")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(adaptiveDetailsCornerRadius)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: adaptiveButtonSpacing) {
                // History button
                Button(action: {
                    showingHistory = true
                }) {
                    HStack(spacing: adaptiveHistoryButtonIconSpacing) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: adaptiveHistoryButtonIconSize))
                        Text("View History")
                            .font(.system(size: adaptiveHistoryButtonFontSize))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: adaptiveHistoryButtonMaxWidth)
                    .frame(height: adaptiveHistoryButtonHeight)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(adaptiveHistoryButtonCornerRadius)
                }
            }
        }
        .padding(.horizontal, adaptiveHorizontalPadding)
        .padding(.vertical, adaptiveVerticalPadding)
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveVerticalSpacing: CGFloat {
        isLargeDevice ? 40 : 30
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 32 : 28
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveRatingSpacing: CGFloat {
        isLargeDevice ? 24 : 20
    }
    
    private var adaptiveRatingTitleSize: CGFloat {
        isLargeDevice ? 24 : 20
    }
    
    private var adaptiveStarSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveStarSize: CGFloat {
        isLargeDevice ? 40 : 32
    }
    
    private var adaptiveNotesSpacing: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveNotesTitleSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveTextFieldSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveTextFieldPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveTextFieldCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveHistoryButtonIconSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveHistoryButtonIconSize: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveHistoryButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveHistoryButtonMaxWidth: CGFloat {
        isLargeDevice ? 300 : 250
    }
    
    private var adaptiveHistoryButtonHeight: CGFloat {
        isLargeDevice ? 56 : 48
    }
    
    private var adaptiveHistoryButtonCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 40 : 30
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 40 : 30
    }
    
    // MARK: - Computed Properties
    
    private var hasFermentationDetails: Bool {
        currentFermentation?.scobyName != nil || 
        currentFermentation?.teaType != nil || 
        currentFermentation?.sugar != nil || 
        currentFermentation?.starterLiquidAmount != nil || 
        currentFermentation?.activeNotes != nil
    }
    
    // MARK: - Fermentation Details Adaptive Properties
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 20 : 16
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
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack {
                    if fermentationManager.fermentationHistory.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Fermentation History")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Your completed fermentations will appear here")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        // History list
                        List {
                            ForEach(fermentationManager.fermentationHistory, id: \.id) { fermentation in
                                HistoryRow(
                                    fermentation: fermentation,
                                    onEdit: { /* Edit functionality not needed in this context */ },
                                    onDelete: { /* Delete functionality not needed in this context */ }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fermentation History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
}

#Preview {
    RatingAndNotesSheet()
        .environmentObject(FermentationManager())
} 



