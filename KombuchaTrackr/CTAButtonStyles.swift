//
//  CTAButtonStyles.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI

// MARK: - CTA Button Style System

enum CTAButtonStyle {
    case primary     // Green background, white text - for main actions
    case secondary   // Green text, green opacity background - for secondary actions
    case destructive // Red background, white text - for destructive actions
    case outline     // Green border, white background - for tertiary actions
    case text        // Green text, no background - for navigation/minimal actions

    var backgroundColor: Color {
        switch self {
        case .primary: return .green
        case .secondary: return Color.green.opacity(0.1)
        case .destructive: return .red
        case .outline: return .white
        case .text: return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary, .destructive: return .white
        case .secondary, .outline, .text: return .green
        }
    }

    var borderColor: Color? {
        switch self {
        case .outline: return .green
        default: return nil
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .outline: return 2
        default: return 0
        }
    }

    var hasShadow: Bool {
        switch self {
        case .primary, .destructive: return true
        default: return false
        }
    }
}

// MARK: - CTA Button Component

struct CTAButton<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let style: CTAButtonStyle
    let action: () -> Void
    let content: () -> Content

    init(style: CTAButtonStyle, action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: action) {
            content()
                .font(.system(size: adaptiveFontSize, weight: adaptiveFontWeight))
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: adaptiveHeight)
                .background(style.backgroundColor)
                .cornerRadius(adaptiveCornerRadius)
                .overlay(
                    style.borderColor.map { color in
                        RoundedRectangle(cornerRadius: adaptiveCornerRadius)
                            .stroke(color, lineWidth: style.borderWidth)
                    }
                )
                .shadow(
                    color: style.hasShadow ? Color.black.opacity(0.1) : .clear,
                    radius: style.hasShadow ? 3 : 0,
                    x: style.hasShadow ? 0 : 0,
                    y: style.hasShadow ? 2 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Adaptive Layout Properties

    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }

    private var adaptiveFontSize: CGFloat {
        isLargeDevice ? 18 : 16
    }

    private var adaptiveFontWeight: Font.Weight {
        switch style {
        case .primary, .destructive: return .semibold
        case .secondary, .outline: return .medium
        case .text: return .regular
        }
    }

    private var adaptiveHeight: CGFloat {
        isLargeDevice ? 48 : 44
    }

    private var adaptiveCornerRadius: CGFloat {
        isLargeDevice ? 12 : 10
    }
}

// MARK: - Convenience Initializers

extension CTAButton where Content == Text {
    init(_ title: String, style: CTAButtonStyle, action: @escaping () -> Void) {
        self.init(style: style, action: action) {
            Text(title)
        }
    }
}

extension CTAButton {
    init(_ title: String, systemImage: String, style: CTAButtonStyle, action: @escaping () -> Void) where Content == HStack<TupleView<(Image, Text)>> {
        self.init(style: style, action: action) {
            HStack(spacing: adaptiveIconSpacing) {
                Image(systemName: systemImage)
                    .font(.system(size: adaptiveIconSize, weight: .medium))
                Text(title)
            }
        }
    }

    private var adaptiveIconSpacing: CGFloat {
        isLargeDevice ? 8 : 6
    }

    private var adaptiveIconSize: CGFloat {
        isLargeDevice ? 16 : 14
    }
}

// MARK: - Icon Button Component

struct CTAIconButton: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let style: CTAButtonStyle
    let systemImage: String
    let action: () -> Void

    init(style: CTAButtonStyle, systemImage: String, action: @escaping () -> Void) {
        self.style = style
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: adaptiveIconSize, weight: .medium))
                .foregroundColor(style.foregroundColor)
                .frame(width: adaptiveButtonSize, height: adaptiveButtonSize)
                .background(style.backgroundColor)
                .cornerRadius(adaptiveCornerRadius)
                .overlay(
                    style.borderColor.map { color in
                        RoundedRectangle(cornerRadius: adaptiveCornerRadius)
                            .stroke(color, lineWidth: style.borderWidth)
                    }
                )
                .shadow(
                    color: style.hasShadow ? Color.black.opacity(0.1) : .clear,
                    radius: style.hasShadow ? 2 : 0,
                    x: style.hasShadow ? 0 : 0,
                    y: style.hasShadow ? 1 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Adaptive Layout Properties

    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }

    private var adaptiveIconSize: CGFloat {
        isLargeDevice ? 16 : 14
    }

    private var adaptiveButtonSize: CGFloat {
        isLargeDevice ? 44 : 40
    }

    private var adaptiveCornerRadius: CGFloat {
        isLargeDevice ? 10 : 8
    }
}

// MARK: - Star Rating Component

struct CTARatingView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Binding var rating: Int
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: adaptiveSpacing) {
            ForEach(1...maxRating, id: \.self) { star in
                Button(action: {
                    rating = star
                }) {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: adaptiveStarSize))
                        .foregroundColor(star <= rating ? .yellow : .gray)
                }
            }
        }
    }

    // MARK: - Adaptive Layout Properties

    private var isLargeDevice: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .regular
    }

    private var adaptiveSpacing: CGFloat {
        isLargeDevice ? 12 : 8
    }

    private var adaptiveStarSize: CGFloat {
        isLargeDevice ? 32 : 24
    }
}

#Preview {
    VStack(spacing: 20) {
        CTAButton("Primary Button", style: .primary, action: {})
        CTAButton("Secondary Button", style: .secondary, action: {})
        CTAButton("Destructive Button", style: .destructive, action: {})
        CTAButton("Outline Button", style: .outline, action: {})
        CTAButton("Text Button", style: .text, action: {})

        CTAButton("Button with Icon", systemImage: "plus.circle.fill", style: .primary, action: {})

        CTAIconButton(style: .secondary, systemImage: "pencil", action: {})

        CTARatingView(rating: .constant(3))
    }
    .padding()
}
