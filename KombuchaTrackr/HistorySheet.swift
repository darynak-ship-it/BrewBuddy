//
//  HistorySheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct HistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var editingFermentation: Fermentation?
    @State private var showingDeleteAlert = false
    @State private var fermentationToDelete: Fermentation?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack {
                    if fermentationManager.fermentationHistory.isEmpty {
                        // Empty state
                        VStack(spacing: adaptiveEmptyStateSpacing) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: adaptiveEmptyStateIconSize))
                                .foregroundColor(.gray)
                            
                            Text("No Fermentation History")
                                .font(.system(size: adaptiveEmptyStateTitleSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("Your completed fermentations will appear here")
                                .font(.system(size: adaptiveEmptyStateSubtitleSize))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    } else {
                        // History list
                        List {
                            ForEach(fermentationManager.fermentationHistory, id: \.id) { fermentation in
                                HistoryRow(
                                    fermentation: fermentation,
                                    onEdit: { editingFermentation = fermentation },
                                    onDelete: {
                                        fermentationToDelete = fermentation
                                        showingDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.white)
                    }
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
            }
            .navigationTitle("Fermentation History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .alert("Delete Fermentation", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let fermentation = fermentationToDelete {
                    fermentationManager.deleteFromHistory(fermentation)
                }
            }
        } message: {
            Text("Are you sure you want to delete this fermentation? This action cannot be undone.")
        }
        .fullScreenCover(item: $editingFermentation) { fermentation in
            EditHistoryFermentationSheet(fermentation: fermentation)
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveEmptyStateSpacing: CGFloat {
        isLargeDevice ? 18 : 12
    }
    
    private var adaptiveEmptyStateIconSize: CGFloat {
        isLargeDevice ? 70 : 50
    }
    
    private var adaptiveEmptyStateTitleSize: CGFloat {
        isLargeDevice ? 22 : 18
    }
    
    private var adaptiveEmptyStateSubtitleSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
}

struct HistoryRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let fermentation: Fermentation
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: adaptiveRowSpacing) {
            // Header with name and rating
            HStack {
                VStack(alignment: .leading, spacing: adaptiveHeaderSpacing) {
                    Text(fermentation.name)
                        .font(.system(size: adaptiveNameFontSize, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Completed \(fermentation.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: adaptiveDateFontSize))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if let rating = fermentation.rating {
                    HStack(spacing: adaptiveRatingSpacing) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: adaptiveStarSize))
                                .foregroundColor(star <= rating ? .yellow : .gray)
                        }
                    }
                }
            }
            
            // Notes
            if let notes = fermentation.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: adaptiveNotesFontSize))
                    .foregroundColor(.black)
                    .padding(.top, adaptiveNotesTopPadding)
            }
            
            // Fermentation Details
            VStack(alignment: .leading, spacing: adaptiveDetailsSpacing) {
                if let scobyName = fermentation.scobyName, !scobyName.isEmpty {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: adaptiveDetailIconSize))
                            .foregroundColor(.green)
                        Text("SCOBY: \(scobyName)")
                            .font(.system(size: adaptiveDetailTextSize))
                            .foregroundColor(.black)
                    }
                }
                
                if let teaType = fermentation.teaType {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: adaptiveDetailIconSize))
                            .foregroundColor(.brown)
                        Text("Tea: \(teaType.displayName)")
                            .font(.system(size: adaptiveDetailTextSize))
                            .foregroundColor(.black)
                    }
                }
                
                if let sugar = fermentation.sugar, !sugar.isEmpty {
                    HStack {
                        Image(systemName: "drop.fill")
                            .font(.system(size: adaptiveDetailIconSize))
                            .foregroundColor(.orange)
                        Text("Sugar: \(sugar)")
                            .font(.system(size: adaptiveDetailTextSize))
                            .foregroundColor(.black)
                    }
                }
                
                if let starterLiquidAmount = fermentation.starterLiquidAmount, !starterLiquidAmount.isEmpty {
                    HStack {
                        Image(systemName: "drop.fill")
                            .font(.system(size: adaptiveDetailIconSize))
                            .foregroundColor(.blue)
                        Text("Starter: \(starterLiquidAmount)")
                            .font(.system(size: adaptiveDetailTextSize))
                            .foregroundColor(.black)
                    }
                }
                
                if let activeNotes = fermentation.activeNotes, !activeNotes.isEmpty {
                    HStack {
                        Image(systemName: "note.text")
                            .font(.system(size: adaptiveDetailIconSize))
                            .foregroundColor(.purple)
                        Text("Notes: \(activeNotes)")
                            .font(.system(size: adaptiveDetailTextSize))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.top, adaptiveDetailsTopPadding)
            
            // Action buttons
            HStack(spacing: adaptiveActionButtonSpacing) {
                // Edit button (secondary style since it's not the primary action)
                CTAButton("Edit", systemImage: "pencil", style: .secondary, action: onEdit)

                // Delete button (destructive action)
                CTAButton("Delete", systemImage: "trash", style: .destructive, action: onDelete)
            }
        }
        .padding(adaptiveRowPadding)
        .background(Color.white)
        .cornerRadius(adaptiveRowCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: adaptiveRowCornerRadius)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveRowSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveNameFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveDateFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveRatingSpacing: CGFloat {
        isLargeDevice ? 4 : 2
    }
    
    private var adaptiveStarSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveNotesFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveNotesTopPadding: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveDetailsTopPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveDetailIconSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveDetailTextSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveActionButtonSpacing: CGFloat {
        isLargeDevice ? 18 : 14
    }
    
    private var adaptiveEditButtonIconSpacing: CGFloat {
        isLargeDevice ? 6 : 4
    }
    
    private var adaptiveEditButtonIconSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveEditButtonFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveDeleteButtonIconSpacing: CGFloat {
        isLargeDevice ? 6 : 4
    }
    
    private var adaptiveDeleteButtonIconSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveDeleteButtonFontSize: CGFloat {
        isLargeDevice ? 14 : 12
    }
    
    private var adaptiveActionButtonHeight: CGFloat {
        isLargeDevice ? 40 : 36
    }
    
    private var adaptiveActionButtonCornerRadius: CGFloat {
        isLargeDevice ? 8 : 6
    }
    
    private var adaptiveRowPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveRowCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
}

#Preview {
    HistorySheet()
        .environmentObject(FermentationManager())
}

struct EditHistoryFermentationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let fermentation: Fermentation
    
    @State private var selectedRating: Int
    @State private var notes: String
    @State private var scobyName: String
    @State private var selectedTeaType: TeaType
    @State private var sugar: String
    @State private var starterLiquidAmount: String
    @State private var activeNotes: String
    
    init(fermentation: Fermentation) {
        self.fermentation = fermentation
        
        // Initialize with current values
        self._selectedRating = State(initialValue: fermentation.rating ?? 0)
        self._notes = State(initialValue: fermentation.notes ?? "")
        self._scobyName = State(initialValue: fermentation.scobyName ?? "")
        self._selectedTeaType = State(initialValue: fermentation.teaType ?? .black)
        self._sugar = State(initialValue: fermentation.sugar ?? "")
        self._starterLiquidAmount = State(initialValue: fermentation.starterLiquidAmount ?? "")
        self._activeNotes = State(initialValue: fermentation.activeNotes ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: adaptiveVerticalSpacing) {
                    // Header
                    VStack(spacing: adaptiveHeaderSpacing) {
                        Text("Edit Fermentation")
                            .font(.system(size: adaptiveTitleSize, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Update fermentation details")
                            .font(.system(size: adaptiveSubtitleSize))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Rating section
                    VStack(spacing: adaptiveRatingSpacing) {
                        Text("Rating")
                            .font(.system(size: adaptiveRatingTitleSize, weight: .semibold))
                            .foregroundColor(.black)
                        
                        CTARatingView(rating: $selectedRating)
                    }
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: adaptiveNotesSpacing) {
                        Text("Notes")
                            .font(.system(size: adaptiveNotesTitleSize, weight: .semibold))
                            .foregroundColor(.black)
                        
                        TextField("Add notes...", text: $notes)
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
                    VStack(alignment: .leading, spacing: adaptiveDetailsSpacing) {
                        Text("Fermentation Details")
                            .font(.system(size: adaptiveDetailsTitleSize, weight: .semibold))
                            .foregroundColor(.black)
                        
                        // SCOBY Name
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("SCOBY's Name")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("Enter SCOBY name...", text: $scobyName)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveTextFieldCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Tea Type
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Tea Type")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            Picker("Tea Type", selection: $selectedTeaType) {
                                ForEach(TeaType.allCases, id: \.self) { teaType in
                                    Text(teaType.displayName).tag(teaType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .frame(height: adaptiveTextFieldHeight)
                            .padding(.horizontal, adaptiveTextFieldPadding)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(adaptiveTextFieldCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Sugar
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Sugar")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("e.g., 1 cup white sugar", text: $sugar)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveTextFieldCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Starter Liquid Amount
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Starter Liquid Amount")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("e.g., 2 cups", text: $starterLiquidAmount)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveTextFieldCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Active Notes
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Notes")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("Add fermentation notes...", text: $activeNotes)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveTextFieldCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: adaptiveButtonSpacing) {
                        CTAButton("Cancel", style: .outline, action: {
                            dismiss()
                        })

                        CTAButton("Save Changes", style: .primary, action: saveChanges)
                    }
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
                .padding(.vertical, adaptiveVerticalPadding)
            }
            .navigationTitle("Edit Fermentation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func saveChanges() {
        // Create updated fermentation
        let updatedFermentation = Fermentation(
            id: fermentation.id,
            name: fermentation.name,
            startDate: fermentation.startDate,
            endDate: fermentation.endDate,
            durationDays: fermentation.durationDays,
            rating: selectedRating,
            notes: notes,
            scobyName: scobyName.isEmpty ? nil : scobyName,
            teaType: selectedTeaType,
            sugar: sugar.isEmpty ? nil : sugar,
            starterLiquidAmount: starterLiquidAmount.isEmpty ? nil : starterLiquidAmount,
            activeNotes: activeNotes.isEmpty ? nil : activeNotes
        )
        
        // Update in manager
        fermentationManager.updateHistoryFermentation(updatedFermentation)
        
        dismiss()
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveVerticalSpacing: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 28 : 24
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 16 : 14
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
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 24 : 20
    }
    
    private var adaptiveDetailsTitleSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveFieldSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveFieldLabelSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldHeight: CGFloat {
        isLargeDevice ? 48 : 44
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveButtonFontSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveButtonHeight: CGFloat {
        isLargeDevice ? 48 : 44
    }
    
    private var adaptiveButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
} 