//
//  AddNotesSheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct AddNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fermentationManager: FermentationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var scobyName = ""
    @State private var selectedTeaType: TeaType = .black
    @State private var sugar = ""
    @State private var starterLiquidAmount = ""
    @State private var activeNotes = ""
    
    let fermentationDays: Int
    let onNotesCompleted: (String?, TeaType?, String?, String?, String?) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: adaptiveVerticalSpacing) {
                    // Header
                    VStack(spacing: adaptiveHeaderSpacing) {
                        Text("Add Notes")
                            .font(.system(size: adaptiveTitleSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    // Brew Buddy Note Image
                    Image("brew_buddy_note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: adaptiveImageHeight)
                        .padding(.vertical, adaptiveImagePadding)
                    
                    // Notes form
                    VStack(spacing: adaptiveFormSpacing) {
                        // SCOBY Name
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("SCOBY's Name:")
                                .font(.system(size: adaptiveLabelSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter SCOBY name", text: $scobyName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: adaptiveTextFieldSize))
                        }
                        
                        // Tea Type
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Tea:")
                                .font(.system(size: adaptiveLabelSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Picker("Tea Type", selection: $selectedTeaType) {
                                ForEach(TeaType.allCases, id: \.self) { teaType in
                                    Text(teaType.displayName).tag(teaType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(adaptivePickerCornerRadius)
                        }
                        
                        // Sugar
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Sugar:")
                                .font(.system(size: adaptiveLabelSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("e.g., 1 cup white sugar", text: $sugar)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: adaptiveTextFieldSize))
                        }
                        
                        // Starter Liquid Amount
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Starter Liquid Amount:")
                                .font(.system(size: adaptiveLabelSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("e.g., 2 cups", text: $starterLiquidAmount)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: adaptiveTextFieldSize))
                        }
                        
                        // Additional Notes
                        VStack(alignment: .leading, spacing: adaptiveFieldSpacing) {
                            Text("Additional Notes:")
                                .font(.system(size: adaptiveLabelSize, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Any other details...", text: $activeNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: adaptiveTextFieldSize))
                                .frame(height: 80)
                        }
                    }
                    .padding(.horizontal, adaptiveFormHorizontalPadding)
                    
                    // Action buttons
                    VStack(spacing: adaptiveButtonSpacing) {
                        Button(action: saveNotes) {
                            Text("Save")
                                .font(.system(size: adaptiveSaveButtonFontSize, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: adaptiveSaveButtonHeight)
                                .background(Color.green)
                                .cornerRadius(adaptiveSaveButtonCornerRadius)
                        }
                        
                        Button(action: skipNotes) {
                            Text("Skip")
                                .font(.system(size: adaptiveSkipButtonFontSize, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: adaptiveSkipButtonHeight)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(adaptiveSkipButtonCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: adaptiveSkipButtonCornerRadius)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
                .padding(.vertical, adaptiveVerticalPadding)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func saveNotes() {
        let scobyNameValue = scobyName.isEmpty ? nil : scobyName
        let sugarValue = sugar.isEmpty ? nil : sugar
        let starterLiquidValue = starterLiquidAmount.isEmpty ? nil : starterLiquidAmount
        let notesValue = activeNotes.isEmpty ? nil : activeNotes
        
        onNotesCompleted(scobyNameValue, selectedTeaType, sugarValue, starterLiquidValue, notesValue)
        dismiss()
    }
    
    private func skipNotes() {
        onNotesCompleted(nil, nil, nil, nil, nil)
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
    
    private var adaptiveImageHeight: CGFloat {
        isLargeDevice ? 180 : 140
    }
    
    private var adaptiveImagePadding: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveFormSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveFieldSpacing: CGFloat {
        isLargeDevice ? 6 : 4
    }
    
    private var adaptiveLabelSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptivePickerCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
    
    private var adaptiveFormHorizontalPadding: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveButtonSpacing: CGFloat {
        isLargeDevice ? 10 : 8
    }
    
    private var adaptiveSaveButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveSaveButtonHeight: CGFloat {
        isLargeDevice ? 48 : 40
    }
    
    private var adaptiveSaveButtonCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveSkipButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveSkipButtonHeight: CGFloat {
        isLargeDevice ? 48 : 40
    }
    
    private var adaptiveSkipButtonCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 25 : 20
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
}

#Preview {
    AddNotesSheet(
        fermentationDays: 7,
        onNotesCompleted: { _, _, _, _, _ in }
    )
    .environmentObject(FermentationManager())
}
