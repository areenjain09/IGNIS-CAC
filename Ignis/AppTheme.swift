import SwiftUI

// MARK: - Unified App Theme System
// A cohesive dark theme with warm, uplifting vibes

extension Color {
    // MARK: - Unified Dark Theme Colors
    
    // Primary Background Colors
    static let appBackground = Color(red: 28/255, green: 25/255, blue: 23/255)          // Warm charcoal
    static let appSurface = Color(red: 38/255, green: 35/255, blue: 33/255)            // Elevated surface
    static let appCard = Color(red: 48/255, green: 44/255, blue: 41/255)               // Card background
    
    // Accent Colors (Fire-themed but elegant)
    static let appPrimary = Color(red: 255/255, green: 138/255, blue: 76/255)          // Warm orange
    static let appSecondary = Color(red: 255/255, green: 183/255, blue: 107/255)       // Golden orange
    static let appAccent = Color(red: 255/255, green: 206/255, blue: 146/255)          // Light gold
    
    // Text Colors
    static let appTextPrimary = Color(red: 250/255, green: 248/255, blue: 246/255)     // Warm white
    static let appTextSecondary = Color(red: 190/255, green: 185/255, blue: 180/255)   // Muted text
    static let appTextTertiary = Color(red: 140/255, green: 135/255, blue: 130/255)    // Subtle text
    
    // Status Colors (Consistent across all views)
    static let appSuccess = Color(red: 134/255, green: 239/255, blue: 172/255)         // Soft green
    static let appWarning = Color(red: 251/255, green: 191/255, blue: 36/255)          // Warm yellow
    static let appError = Color(red: 248/255, green: 113/255, blue: 113/255)           // Soft red
    static let appInfo = Color(red: 96/255, green: 165/255, blue: 250/255)             // Soft blue
    
    // Interactive Elements
    static let appButtonPrimary = Color(red: 255/255, green: 138/255, blue: 76/255)    // Same as primary
    static let appButtonSecondary = Color(red: 68/255, green: 64/255, blue: 61/255)    // Dark button
    static let appBorder = Color(red: 68/255, green: 64/255, blue: 61/255)             // Subtle borders
    
    // Gradients
    static let appGradientPrimary = LinearGradient(
        colors: [appPrimary, appSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let appGradientBackground = LinearGradient(
        colors: [
            Color(red: 28/255, green: 25/255, blue: 23/255),    // Warm charcoal
            Color(red: 33/255, green: 30/255, blue: 28/255),    // Slightly lighter
            Color(red: 38/255, green: 35/255, blue: 33/255)     // Surface color
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let appGradientCard = LinearGradient(
        colors: [
            Color(red: 48/255, green: 44/255, blue: 41/255),    // Card base
            Color(red: 53/255, green: 49/255, blue: 46/255)     // Slightly elevated
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Legacy Colors (Keep for compatibility during transition)
    // These will be gradually replaced
    static let wsOrange = appPrimary
    static let wsYellow = appSecondary
    static let wsRed = appError
    static let wsDark = appBackground
    
    // Education View Colors (Updated to match theme)
    static let lightOrange = appPrimary
    static let softOrange = appSecondary
    static let cream = appCard
    static let warmGray = appTextSecondary
    static let lightGray = appBorder
    static let darkText = appTextPrimary
}

// MARK: - Theme Modifiers
extension View {
    // Card styling
    func appCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appGradientCard)
                    .shadow(color: Color.appPrimary.opacity(0.05), radius: 8, x: 0, y: 4)
            )
    }
    
    // Primary button styling
    func appButtonPrimary() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appGradientPrimary)
                    .shadow(color: Color.appPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
            )
    }
    
    // Secondary button styling
    func appButtonSecondary() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appButtonSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
            )
    }
    
    // Text input styling
    func appInputStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Typography System
extension Font {
    // App-specific font sizes
    static let appTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let appHeadline = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let appSubheadline = Font.system(size: 18, weight: .medium, design: .default)
    static let appBody = Font.system(size: 16, weight: .regular, design: .default)
    static let appCaption = Font.system(size: 14, weight: .medium, design: .default)
    static let appSmall = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Animation Presets
extension Animation {
    static let appSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let appEaseOut = Animation.easeOut(duration: 0.3)
    static let appEaseIn = Animation.easeIn(duration: 0.2)
}
