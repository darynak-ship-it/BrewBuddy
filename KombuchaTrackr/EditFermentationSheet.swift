//
//  EditFermentationSheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct EditFermentationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let fermentationID: String

    @State private var selectedDays: Int
    @State private var scobyName: String
    @State private var selectedTeaType: TeaType
    @State private var sugar: String
    @State private var starterLiquidAmount: String
    @State private var activeNotes: String
    
    private var fermentation: Fermentation? {
        fermentationManager.activeFermentations.first { $0.id == fermentationID }
    }
    
    init(fermentationID: String) {
        self.fermentationID = fermentationID
        
        // Initialize with default values, will be updated in onAppear
        self._selectedDays = State(initialValue: 7)
        self._scobyName = State(initialValue: "")
        self._selectedTeaType = State(initialValue: .black)
        self._sugar = State(initialValue: "")
        self._starterLiquidAmount = State(initialValue: "")
        self._activeNotes = State(initialValue: "")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: adaptiveVerticalSpacing) {
                    // Header
                    VStack(spacing: adaptiveHeaderSpacing) {
                        Text("Edit Duration")
                            .font(.system(size: adaptiveTitleSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    // Custom duration input
                    VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                        Text("How many days?")
                            .font(.system(size: adaptiveFieldLabelSize, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("", value: $selectedDays, format: .number)
                            .font(.system(size: adaptiveTextFieldSize + 4, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(adaptiveTextFieldCornerRadius + 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius + 4)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 2)
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                    }
                    
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
                                .padding(.horizontal, adaptiveTextFieldPadding)
                                .padding(.vertical, adaptiveTextFieldPadding)
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
                            .padding(.horizontal, adaptiveTextFieldPadding)
                            .padding(.vertical, adaptiveTextFieldPadding)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(adaptiveTextFieldCornerRadius)
                        }
                        
                        // Sugar
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Sugar")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("e.g., 1 cup white sugar", text: $sugar)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(.horizontal, adaptiveTextFieldPadding)
                                .padding(.vertical, adaptiveTextFieldPadding)
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
                                .padding(.horizontal, adaptiveTextFieldPadding)
                                .padding(.vertical, adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Additional Notes
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Additional Notes")
                                .font(.system(size: adaptiveFieldLabelSize))
                                .foregroundColor(.black)
                            
                            TextField("Any other details...", text: $activeNotes)
                                .font(.system(size: adaptiveTextFieldSize))
                                .padding(.horizontal, adaptiveTextFieldPadding)
                                .padding(.vertical, adaptiveTextFieldPadding)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveTextFieldCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveTextFieldCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .frame(height: 80)
                        }
                    }
                    
                    // Save button
                    CTAButton("Update Duration", style: .primary, action: saveChanges)
                        .padding(.top, 20)
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
                .padding(.top, adaptiveVerticalPadding)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
            .onAppear {
            loadFermentationData()
        }
    }
    
    private func loadFermentationData() {
        guard let fermentation = fermentation else { return }
        
        selectedDays = fermentation.durationDays
        scobyName = fermentation.scobyName ?? ""
        selectedTeaType = fermentation.teaType ?? .black
        sugar = fermentation.sugar ?? ""
        starterLiquidAmount = fermentation.starterLiquidAmount ?? ""
        activeNotes = fermentation.activeNotes ?? ""
    }
    
    private func saveChanges() {
        guard let fermentation = fermentation else { return }
        
        // Update duration if changed
        if selectedDays != fermentation.durationDays {
            fermentationManager.updateFermentationDuration(id: fermentationID, days: selectedDays)
        }
        
        // Update fermentation details
        fermentationManager.updateFermentationDetails(
            id: fermentationID,
            scobyName: scobyName.isEmpty ? nil : scobyName,
            teaType: selectedTeaType,
            sugar: sugar.isEmpty ? nil : sugar,
            starterLiquidAmount: starterLiquidAmount.isEmpty ? nil : starterLiquidAmount,
            activeNotes: activeNotes.isEmpty ? nil : activeNotes
        )
        
        dismiss()
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var adaptiveVerticalSpacing: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveHeaderSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveTitleSize: CGFloat {
        isLargeDevice ? 28 : 24
    }
    
    private var adaptiveSubtitleSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveDurationSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveDurationTitleSize: CGFloat {
        isLargeDevice ? 20 : 18
    }
    
    private var adaptiveDurationButtonSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveDurationButtonFontSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveDurationButtonHeight: CGFloat {
        isLargeDevice ? 44 : 40
    }
    
    private var adaptiveDurationButtonCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveDetailsTitleSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveFieldSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveFieldLabelSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldPadding: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveTextFieldHeight: CGFloat {
        isLargeDevice ? 44 : 40
    }
    
    private var adaptiveTextFieldCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 18 : 14
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

#Preview {
    EditFermentationSheet(fermentationID: "test")
        .environmentObject(FermentationManager())
} 
