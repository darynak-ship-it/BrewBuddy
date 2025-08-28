//
//  FermentationDetailsSheet.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

struct FermentationDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Binding var scobyName: String
    @Binding var selectedTeaType: TeaType
    @Binding var sugar: String
    @Binding var starterLiquidAmount: String
    @Binding var activeNotes: String
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(.all)
                
                VStack(spacing: adaptiveVerticalSpacing) {
                    // Header
                    VStack(spacing: adaptiveHeaderSpacing) {
                        Text("Fermentation Details")
                            .font(.system(size: adaptiveTitleSize, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Configure your fermentation setup")
                            .font(.system(size: adaptiveSubtitleSize))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Brew Buddy Note Image
                    Image("brew_buddy_note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: adaptiveImageHeight)
                        .padding(.vertical, adaptiveImagePadding)
                    
                    // Fermentation Details Form
                    VStack(alignment: .leading, spacing: adaptiveDetailsSpacing) {
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
                    
                    // Save button
                    Button(action: saveDetails) {
                        Text("Save Details")
                            .font(.system(size: adaptiveSaveButtonFontSize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: adaptiveSaveButtonHeight)
                            .background(Color.green)
                            .cornerRadius(adaptiveSaveButtonCornerRadius)
                    }
                }
                .padding(.horizontal, adaptiveHorizontalPadding)
                .padding(.vertical, adaptiveVerticalPadding)
            }
            .navigationTitle("Fermentation Details")
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
    }
    
    private func saveDetails() {
        onSave()
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
    
    private var adaptiveImageHeight: CGFloat {
        isLargeDevice ? 120 : 100
    }
    
    private var adaptiveImagePadding: CGFloat {
        isLargeDevice ? 20 : 16
    }
    
    private var adaptiveDetailsSpacing: CGFloat {
        isLargeDevice ? 24 : 20
    }
    
    private var adaptiveFieldSpacing: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveFieldLabelSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
    
    private var adaptiveTextFieldPadding: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveTextFieldHeight: CGFloat {
        isLargeDevice ? 48 : 44
    }
    
    private var adaptiveTextFieldCornerRadius: CGFloat {
        isLargeDevice ? 12 : 8
    }
    
    private var adaptiveSaveButtonFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }
    
    private var adaptiveSaveButtonHeight: CGFloat {
        isLargeDevice ? 56 : 48
    }
    
    private var adaptiveSaveButtonCornerRadius: CGFloat {
        isLargeDevice ? 16 : 12
    }
    
    private var adaptiveHorizontalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
    
    private var adaptiveVerticalPadding: CGFloat {
        isLargeDevice ? 30 : 25
    }
}

#Preview {
    FermentationDetailsSheet(
        scobyName: .constant(""),
        selectedTeaType: .constant(.black),
        sugar: .constant(""),
        starterLiquidAmount: .constant(""),
        activeNotes: .constant(""),
        onSave: {}
    )
}
