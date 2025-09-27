//
//  LandingPageView.swift
//  Ignis
//
//  Created by Areen Jain on 7/20/25.
//
import SwiftUI
// MARK: - Notification Names
extension Notification.Name {
    static let enterIgnis = Notification.Name("enterIgnis")
}
/// Landing page view for Ignis application
/// Features real-time statistics and interactive elements
struct LandingPageView: View {
    // MARK: - State Properties
    
    @State private var hoveredCard: StatCardType? = nil
    @State private var ashParticles: [AshParticle] = []
    @State private var burningAshParticles: [BurningAshParticle] = []
    @State private var hoveredPanel: Int? = nil
    @State private var isButtonHovered = false
    @State private var buttonGlowIntensity: Double = 0.0
    
    // MARK: - Callback
    let onStartNow: () -> Void
    
    // MARK: - Data Service
    @StateObject private var fireDataService = FireDataService.shared
    
    // MARK: - Timer for real-time updates (removed - now using FireDataService)
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Realistic fire/ash background
            fireAshBackground
            
            ScrollView {
                VStack(spacing: 40) {
                    // Image panels section
                    imagePanelsSection
                    
                    // Title and CTA section
                    titleAndCTASection
                    
                    // Statistics section
                    statisticsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            generateAshParticles()
            generateBurningAshParticles()
            animateButtonGlow()
            fireDataService.start()
        }
    }
    
    // MARK: - Background
    
    /// Realistic fire/ash background with animated particles
    private var fireAshBackground: some View {
        ZStack {
            // Base background - Unified app theme
            Color.appBackground
                .ignoresSafeArea()
            
            // Animated ash particles (falling)
            ForEach(ashParticles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(
                        Animation.linear(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
            
            // Burning ash particles (rising)
            ForEach(burningAshParticles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.6),
                                Color.red.opacity(0.4),
                                Color.gray.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .animation(
                        Animation.easeOut(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
            
            // Fire glow effect
            RadialGradient(
                colors: [
                    Color.orange.opacity(0.15),
                    Color.red.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Subviews
    
    /// Image panels section with 3 static panels
    private var imagePanelsSection: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
                imagePanel(for: index)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 160)
        .padding(.horizontal, 20)
    }
    
    /// Individual image panel
    private func imagePanel(for index: Int) -> some View {
        Group {
            if index == 0 {
                // First panel: Fire image
                Image("fire_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 120, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if index == 1 {
                // Second panel: Emergency image
                Image("emergency_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 135, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Third panel: Evacuation image
                Image("evacuation_panel")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 120, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .shadow(color: .appPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
    }
    
    
    /// Title and call-to-action section
    private var titleAndCTASection: some View {
        VStack(spacing: 24) {
            // Ignis title with fire icon and burning effect
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        // Fire icon
                        Image(systemName: "flame.fill")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .appPrimary.opacity(0.6), radius: 10, x: 0, y: 5)
                        
                        // Burning ash particles above the fire
                        ForEach(0..<8) { i in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.orange.opacity(0.8),
                                            Color.red.opacity(0.6),
                                            Color.gray.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: CGFloat.random(in: 2...4))
                                .offset(
                                    x: CGFloat.random(in: -15...15),
                                    y: CGFloat.random(in: -25 ... -15)
                                )
                                .opacity(Double.random(in: 0.3...0.7))
                                .animation(
                                    Animation.easeOut(duration: Double.random(in: 1...2))
                                        .repeatForever(autoreverses: false),
                                    value: i
                                )
                        }
                    }
                    
                    Text("IGNIS")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(
                                                    LinearGradient(
                            colors: [.appTextPrimary, .appPrimary, .appSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        )
                }
                
                // Mission statement
                Text("Protecting lives from wildfire threats - in real time")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .italic()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appTextSecondary, .appPrimary.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .shadow(color: .appPrimary.opacity(0.6), radius: 15, x: 0, y: 8)
            
            // Start Now button
            Button(action: { onStartNow() }) {
                Text("START NOW")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            colors: isButtonHovered ? [
                                Color.appPrimary,
                                Color.appSecondary,
                                Color.appAccent
                            ] : [
                                Color.appPrimary.opacity(0.9),
                                Color.appSecondary.opacity(0.8),
                                Color.appAccent.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: isButtonHovered ? .appPrimary.opacity(0.6) : .appPrimary.opacity(0.5 + buttonGlowIntensity * 0.3),
                        radius: isButtonHovered ? 15 : 12 + buttonGlowIntensity * 8,
                        x: 0,
                        y: isButtonHovered ? 8 : 6 + buttonGlowIntensity * 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.appPrimary.opacity(0.6 + buttonGlowIntensity * 0.4), .appSecondary.opacity(0.4 + buttonGlowIntensity * 0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1 + buttonGlowIntensity * 2
                            )
                    )
                    .scaleEffect(isButtonHovered ? 1.05 : 1.0 + buttonGlowIntensity * 0.05)
                    .animation(.easeInOut(duration: 0.2), value: isButtonHovered)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: buttonGlowIntensity)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isButtonHovered = hovering
            }
        }
    }
    
    /// Statistics section with 2x2 grid
    private var statisticsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(
                type: .assistedSurvivors,
                value: fireDataService.nasaFireStatistics?.activeFiresLast24Hours ?? 0,
                icon: "flame.fill",
                iconColor: .orange,
                label: "Active fires (24h)",
                isHovered: false,
                isLoading: fireDataService.isLoading || fireDataService.nasaFireStatistics == nil
            ) {
                // No hover action
            } onHoverExit: {
                // No hover exit action
            }
            
            StatCard(
                type: .injuriesPrevented,
                value: fireDataService.nasaFireStatistics?.totalFirePoints ?? 0,
                icon: "location.fill",
                iconColor: .blue,
                label: "Fire detections",
                isHovered: false,
                isLoading: fireDataService.isLoading || fireDataService.nasaFireStatistics == nil
            ) {
                // No hover action
            } onHoverExit: {
                // No hover exit action
            }
            
            StatCard(
                type: .routesProvided,
                value: fireDataService.nasaFireStatistics?.highConfidenceFiresLast24Hours ?? 0,
                icon: "exclamationmark.triangle.fill",
                iconColor: .red,
                label: "High confidence fires",
                isHovered: false,
                isLoading: fireDataService.isLoading || fireDataService.nasaFireStatistics == nil
            ) {
                // No hover action
            } onHoverExit: {
                // No hover exit action
            }
            
            StatCard(
                type: .homesProtected,
                value: Int(fireDataService.nasaFireStatistics?.totalFireRadiativePower ?? 0),
                icon: "bolt.fill",
                iconColor: .yellow,
                label: "Total fire power (MW)",
                isHovered: false,
                isLoading: fireDataService.isLoading || fireDataService.nasaFireStatistics == nil
            ) {
                // No hover action
            } onHoverExit: {
                // No hover exit action
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helper Methods
    
    /// Get image icon for panel
    private func imageIcon(for index: Int) -> String {
        switch index {
        case 0: return "flame.circle.fill"
        case 1: return "shield.lefthalf.filled"
        case 2: return "figure.wave"
        default: return "photo"
        }
    }
    
    /// Get image icon color for panel
    private func imageIconColor(for index: Int) -> LinearGradient {
        switch index {
        case 0: return LinearGradient(colors: [.orange, .red, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 1: return LinearGradient(colors: [.blue, .cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2: return LinearGradient(colors: [.green, .mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.gray, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    /// Get image title for panel
    private func imageTitle(for index: Int) -> String {
        switch index {
        case 0: return "Active Fire"
        case 1: return "Emergency Response"
        case 2: return "Safe Evacuation"
        default: return "Scene"
        }
    }
    
    /// Get image subtitle for panel
    private func imageSubtitle(for index: Int) -> String {
        switch index {
        case 0: return "Live fire map &\nalert system"
        case 1: return "Professional teams\nresponding to emergencies"
        case 2: return "Guided evacuation\nroutes to safety"
        default: return "Scene description"
        }
    }
    
    /// Generate animated ash particles (falling)
    private func generateAshParticles() {
        ashParticles = (0..<50).map { _ in
            AshParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height + 50
                ),
                size: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.1...0.4),
                duration: Double.random(in: 8...15)
            )
        }
        
        // Animate particles falling
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            for i in ashParticles.indices {
                ashParticles[i].position.y = -50
            }
        }
    }
    
    /// Generate burning ash particles (rising)
    private func generateBurningAshParticles() {
        burningAshParticles = (0..<30).map { _ in
            BurningAshParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height + 20
                ),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.2...0.6),
                duration: Double.random(in: 3...8)
            )
        }
        
        // Animate particles rising
        withAnimation(.easeOut(duration: 6).repeatForever(autoreverses: false)) {
            for i in burningAshParticles.indices {
                burningAshParticles[i].position.y = -20
            }
        }
    }
    
    /// Refresh fire data manually
    private func refreshFireData() {
        // disabled while map/data is removed
    }
    
    /// Animate button glow on load
    private func animateButtonGlow() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            buttonGlowIntensity = 1.0
        }
    }
    
    /// Enter Ignis action
    private func enterIgnis() {
        // Post notification to navigate to main content
        NotificationCenter.default.post(name: .enterIgnis, object: nil)
    }
    
    
}
// MARK: - Ash Particle Model
struct AshParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
}
// MARK: - Burning Ash Particle Model
struct BurningAshParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    let duration: Double
}
// MARK: - Stat Card Type
enum StatCardType {
    case assistedSurvivors
    case injuriesPrevented
    case routesProvided
    case homesProtected
}
// MARK: - Stat Card View
struct StatCard: View {
    let type: StatCardType
    let value: Int
    let icon: String
    let iconColor: Color
    let label: String
    let isHovered: Bool
    let isLoading: Bool
    let onHover: () -> Void
    let onHoverExit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [iconColor, iconColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: iconColor.opacity(0.5), radius: 4, x: 0, y: 2)
            
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.appTextPrimary))
                        .scaleEffect(1.2)
                } else {
                    Text("\(value)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
            .frame(height: 40) // Fixed height to prevent layout jumping
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color.appCard
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isHovered ?
                            LinearGradient(
                                colors: [.appPrimary, .appSecondary, iconColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.clear, .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isHovered ? 2 : 0
                        )
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .shadow(
            color: isHovered ? iconColor.opacity(0.4) : Color.black.opacity(0.8),
            radius: isHovered ? 12 : 15,
            x: 0,
            y: isHovered ? 6 : 8
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            if hovering {
                onHover()
            } else {
                onHoverExit()
            }
        }
    }
}
// MARK: - Preview
#Preview {
    LandingPageView(onStartNow: {})
}
