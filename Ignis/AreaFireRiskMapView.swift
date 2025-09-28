//
//  AreaFireRiskMapView.swift
//  Ignis
//
//  Created by Areen Jain on 8/4/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AreaFireRiskMapView: View {
    @StateObject private var areaRiskService = EnhancedFireRiskService.shared
    @StateObject private var locationManager = LocationManager.shared
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179), // California center
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )
    )
    
    @State private var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179), // California center
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
    )
    
    @State private var selectedArea: AreaFireRiskPrediction?
    @State private var showingAreaDetail = false
    @State private var mapStyle: MapStyle = .hybrid
    @State private var mapStyleIsHybrid = true
    @State private var showingLegend = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.01),
                    Color(red: 0.1, green: 0.05, blue: 0.02)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Map View
            Map(position: $cameraPosition) {
                // User location
                if locationManager.location != nil {
                    UserAnnotation()
                }
                
                // Area risk markers
                ForEach(areaRiskService.predictions) { prediction in
                    Annotation(
                        prediction.area.displayName,
                        coordinate: prediction.area.center
                    ) {
                        VStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(prediction.riskColor)
                                .shadow(color: prediction.riskColor.opacity(0.7), radius: prediction.riskLevel == .extreme ? 10 : 0)
                                .scaleEffect(markerScale(for: prediction.riskLevel))
                            
                            Text(prediction.area.displayName)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        .onTapGesture {
                            selectedArea = prediction
                            showingAreaDetail = true
                        }
                    }
                }
            }
            .mapStyle(mapStyle)
            .onMapCameraChange(frequency: .continuous) { context in
                // Update our stored region when user pans/zooms manually
                currentRegion = context.region
            }
            .onAppear {
                setupInitialMapPosition()
                Task {
                    await areaRiskService.calculateAreaRisks()
                }
            }
            
            // Controls overlay
            VStack {
                topControls
                Spacer()
                bottomControls
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedArea) { prediction in
            AreaDetailView(prediction: prediction)
        }
        .sheet(isPresented: $showingLegend) {
            RiskLegendView()
        }
    }
    
    // MARK: - Top Controls
    
    private var topControls: some View {
        VStack(spacing: 12) {
            // Status bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Assessment")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    if areaRiskService.isLoading {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.wsOrange)
                            Text("Calculating risks...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        Text("Updated: \(formatLastUpdated())")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 12) {
                    // Legend button
                    Button(action: { showingLegend = true }) {
                        Image(systemName: "info.circle.fill")
                            .font(.callout)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.wsOrange.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    // Map style toggle
                    Button(action: { toggleMapStyle() }) {
                        Image(systemName: isHybridStyle() ? "map" : "satellite")
                            .font(.callout)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.wsDark.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    // Location button
                    if locationManager.location != nil {
                        Button(action: recenterToUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.callout)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.wsOrange.opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Refresh button
                    Button(action: refreshData) {
                        Image(systemName: "arrow.clockwise")
                            .font(.callout)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.wsDark.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .disabled(areaRiskService.isLoading)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.wsDark.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
        }
    }
    
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        HStack {
            Spacer()
            
            // Zoom controls only
            VStack(spacing: 8) {
                // Zoom in button
                Button(action: zoomIn) {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.wsDark.opacity(0.8))
                        )
                }
                
                // Zoom out button
                Button(action: zoomOut) {
                    Image(systemName: "minus")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.wsDark.opacity(0.8))
                        )
                }
            }
            .padding(.trailing)
            .padding(.bottom, 140) // Increased padding to clear the custom nav bar
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialMapPosition() {
        // Set initial position to California center (same as WildfireMap)
        let californiaCenter = CLLocationCoordinate2D(latitude: 36.7783, longitude: -119.4179)
        let span = MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        let region = MKCoordinateRegion(center: californiaCenter, span: span)
        
        currentRegion = region
        cameraPosition = .region(region)
    }
    
    private func recenterToUserLocation() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let loc = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                )
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentRegion = region
                    cameraPosition = .region(region)
                }
            } else {
                locationManager.startLocationUpdates()
            }
        case .notDetermined:
            locationManager.requestLocationPermission()
        case .denied, .restricted:
            // Optionally surface a subtle prompt elsewhere
            break
        @unknown default:
            break
        }
    }
    
    private func refreshData() {
        Task {
            await areaRiskService.calculateAreaRisks()
        }
    }
    
    private func toggleMapStyle() {
        withAnimation {
            if mapStyleIsHybrid {
                mapStyle = .standard
                mapStyleIsHybrid = false
            } else {
                mapStyle = .hybrid
                mapStyleIsHybrid = true
            }
        }
    }
    
    private func isHybridStyle() -> Bool {
        // Since MapStyle doesn't conform to Equatable, we'll use a state variable
        return mapStyleIsHybrid
    }
    
    private func formatLastUpdated() -> String {
        guard let lastUpdated = areaRiskService.lastUpdated else {
            return "Never"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
    
    private func markerScale(for riskLevel: FireRiskLevel) -> Double {
        switch riskLevel {
        case .low: return 0.8
        case .moderate: return 1.0
        case .high: return 1.2
        case .extreme: return 1.4
        }
    }
    
    // MARK: - Zoom Controls
    
    private func zoomIn() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(currentRegion.span.latitudeDelta * 0.5, 0.01),
            longitudeDelta: max(currentRegion.span.longitudeDelta * 0.5, 0.01)
        )
        currentRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        cameraPosition = .region(currentRegion)
    }
    
    private func zoomOut() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(currentRegion.span.latitudeDelta * 2.0, 180.0),
            longitudeDelta: min(currentRegion.span.longitudeDelta * 2.0, 360.0)
        )
        currentRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        cameraPosition = .region(currentRegion)
    }
}

// MARK: - Area Risk Marker

struct AreaRiskMarker: View {
    let prediction: AreaFireRiskPrediction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow effect for high risk areas
                if prediction.riskLevel == .high || prediction.riskLevel == .extreme {
                    Circle()
                        .fill(prediction.riskColor.opacity(0.3))
                        .frame(width: markerSize + 16, height: markerSize + 16)
                        .blur(radius: 6)
                }
                
                // Main marker
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [prediction.riskColor, prediction.riskColor.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: markerSize, height: markerSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    )
                
                // Risk percentage
                Text("\(prediction.riskPercentage)%")
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var markerSize: CGFloat {
        switch prediction.riskLevel {
        case .extreme: return 50
        case .high: return 44
        case .moderate: return 38
        case .low: return 32
        }
    }
    
    private var fontSize: CGFloat {
        switch prediction.riskLevel {
        case .extreme: return 12
        case .high: return 11
        case .moderate: return 10
        case .low: return 9
        }
    }
}

// MARK: - Area Detail View

struct AreaDetailView: View {
    let prediction: AreaFireRiskPrediction
    @Environment(\.dismiss) private var dismiss
    @StateObject private var shelterService = ShelterService()
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pure black background
                Color.black
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Fire likelihood and confidence
                        firePredictionSection
                        
                        // Weather data from Open-Meteo
                        weatherDataSection
                        
                        // Nearby active fires
                        if !prediction.nearbyFires.isEmpty {
                            nearbyFiresSection
                        }
                        
                        // Nearby shelters
                        nearbySheltersSection
                    }
                    .padding()
                }
            }
            .navigationTitle(prediction.area.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.wsOrange)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Configure navigation bar appearance for dark theme
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                loadNearbyData()
            }
        }
    }
    
    // MARK: - Fire Prediction Section
    
    private var firePredictionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔥 Fire Prediction Analysis")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                // Fire Likelihood
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fire Likelihood")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Probability of wildfire occurrence")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            Circle()
                                .fill(prediction.riskColor)
                                .frame(width: 50, height: 50)
                            
                            Text("\(prediction.riskPercentage)%")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Text(prediction.riskLevel.rawValue.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(prediction.riskColor)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.wsDark.opacity(0.6))
                )
                
                // Prediction Confidence
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Model Confidence")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Reliability of this prediction")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            Circle()
                                .fill(confidenceColor)
                                .frame(width: 50, height: 50)
                            
                            Text("\(Int(prediction.confidence * 100))%")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                        }
                        
                        Text(confidenceLevel)
                            .font(.caption.bold())
                            .foregroundColor(confidenceColor)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.wsDark.opacity(0.6))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wsDark.opacity(0.8))
        )
    }
    
    // MARK: - Weather Data Section
    
    private var weatherDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🌤 Weather Data (Open-Meteo)")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(.wsOrange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Weather Impact")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(prediction.weatherImpact)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.wsDark.opacity(0.6))
                )
                
                // Weather factors from risk factors
                ForEach(weatherRelatedFactors, id: \.name) { factor in
                    HStack {
                        Circle()
                            .fill(getFactorColor(factor.impact))
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(factor.name)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Text(factor.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text("\(Int(factor.impact * 100))%")
                            .font(.caption.bold())
                            .foregroundColor(getFactorColor(factor.impact))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.wsDark.opacity(0.6))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wsDark.opacity(0.8))
        )
    }
    
    // MARK: - Nearby Fires Section
    
    private var nearbyFiresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔥 Nearby Active Fires")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            if prediction.nearbyFires.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text("No active fires detected in this area")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(prediction.nearbyFires.prefix(5)) { fire in
                        HStack {
                            Image(systemName: fire.isActive ? "flame.fill" : "flame")
                                .foregroundColor(fire.isActive ? .red : .orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fire.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                
                                Text("\(String(format: "%.1f", fire.distance)) km away")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("\(Int(fire.acres)) acres burned • \(Int(fire.containment))% contained")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(fire.isActive ? "ACTIVE" : "CONTAINED")
                                    .font(.caption.bold())
                                    .foregroundColor(fire.isActive ? .red : .orange)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(fire.isActive ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(fire.isActive ? Color.red.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wsDark.opacity(0.8))
        )
    }
    
    // MARK: - Nearby Shelters Section
    
    private var nearbySheltersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏠 Nearby Emergency Shelters")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            if shelterService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.wsOrange)
                    
                    Text("Finding nearby shelters...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.wsDark.opacity(0.6))
                )
            } else if shelterService.shelters.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("No shelters found in this area. Contact local emergency services.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(shelterService.shelters.prefix(5)) { shelter in
                        HStack {
                            Image(systemName: shelter.type.icon)
                                .foregroundColor(statusColor(shelter.status))
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(shelter.name)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                
                                Text(shelter.address)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                if let distance = shelter.distance {
                                    Text("\(String(format: "%.1f", distance)) miles away")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Text("Capacity: \(shelter.capacity)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text(shelter.status.rawValue)
                                    .font(.caption.bold())
                                    .foregroundColor(statusColor(shelter.status))
                                
                                Text(shelter.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.wsDark.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(statusColor(shelter.status).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wsDark.opacity(0.8))
        )
    }
    
    // MARK: - Helper Properties and Functions
    
    private var confidenceColor: Color {
        let confidence = prediction.confidence
        if confidence >= 0.8 { return .green }
        else if confidence >= 0.6 { return .yellow }
        else if confidence >= 0.4 { return .orange }
        else { return .red }
    }
    
    private var confidenceLevel: String {
        let confidence = prediction.confidence
        if confidence >= 0.8 { return "HIGH" }
        else if confidence >= 0.6 { return "MEDIUM" }
        else if confidence >= 0.4 { return "LOW" }
        else { return "VERY LOW" }
    }
    
    private var weatherRelatedFactors: [RiskFactor] {
        return prediction.factors.filter { factor in
            let name = factor.name.lowercased()
            return name.contains("temperature") || 
                   name.contains("humidity") || 
                   name.contains("wind") || 
                   name.contains("weather") ||
                   name.contains("precipitation") ||
                   name.contains("drought")
        }
    }
    
    private func loadNearbyData() {
        // Load shelter data for the area
        let areaLocation = CLLocation(
            latitude: prediction.area.center.latitude,
            longitude: prediction.area.center.longitude
        )
        shelterService.fetchNearbyShelters(userLocation: areaLocation)
    }
    
    private func statusColor(_ status: ShelterStatus) -> Color {
        switch status {
        case .open: return .green
        case .closed: return .red
        case .full: return .orange
        case .limited: return .yellow
        case .unknown: return .gray
        }
    }
    
    private func getFactorColor(_ impact: Double) -> Color {
        if impact > 0.6 { return .red }
        else if impact > 0.4 { return .orange }
        else if impact > 0.2 { return .yellow }
        else { return .green }
    }
}

// MARK: - Risk Legend View

struct RiskLegendView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pure black background
                Color.black
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Fire Risk Legend")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            legendItem(level: .extreme, description: "Immediate evacuation may be required")
                            legendItem(level: .high, description: "High fire danger - be prepared to evacuate")
                            legendItem(level: .moderate, description: "Moderate fire risk - stay informed")
                            legendItem(level: .low, description: "Low fire risk - normal activities")
                        }
                        
                        Text("Risk factors include proximity to active fires, weather conditions, historical fire activity, vegetation type, and population density.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Legend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.wsOrange)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Configure navigation bar appearance for dark theme
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
    
    private func legendItem(level: FireRiskLevel, description: String) -> some View {
        HStack {
            Circle()
                .fill(level == .low ? .green : level == .moderate ? .yellow : level == .high ? .orange : .red)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.rawValue.uppercased())
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.wsDark.opacity(0.6))
        )
    }
}

// MARK: - Preview

#Preview {
    AreaFireRiskMapView()
}
