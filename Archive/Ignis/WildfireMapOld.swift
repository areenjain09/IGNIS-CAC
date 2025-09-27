import SwiftUI
import MapKit
import Combine
import UIKit

struct WildfireMap: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.25, longitude: -120.0),
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )
    )
    
    @State private var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.25, longitude: -120.0),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
    )
    
    @State private var selectedIncident: CALFireIncident?
    @State private var showLegend = false
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var mapStyle: MapStyle = .standard

    @StateObject private var dataService = FireDataService()
    @StateObject private var locationManager = LocationManager()
    
    private var filteredIncidents: [CALFireIncident] {
        if searchText.isEmpty {
            return dataService.calFireIncidents
        } else {
            return dataService.calFireIncidents.filter { incident in
                incident.name.localizedCaseInsensitiveContains(searchText) ||
                incident.county.localizedCaseInsensitiveContains(searchText) ||
                incident.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced Map with better styling
                Map(position: $cameraPosition, interactionModes: [.pan, .rotate]) {
                    ForEach(filteredIncidents) { incident in
                        let coord = CLLocationCoordinate2D(latitude: incident.latitude, longitude: incident.longitude)
                        Annotation(incident.name, coordinate: coord) {
                            FireMarkerView(
                                incident: incident,
                                isSelected: selectedIncident?.id == incident.id,
                                onTap: {
                                    selectIncident(incident)
                                }
                            )
                        }
                    }
                }
                .mapStyle(mapStyle)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea()
                .contentShape(Rectangle())
                
                // Subtle gradient overlay for better contrast
                        LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                // Top Controls Bar
                VStack {
                    topControlsBar
                    Spacer()
                }
                
                // Bottom Controls
                VStack {
                    Spacer()
                    HStack {
                        // Legend Button
                        legendButton
                        
                        Spacer()
                        
                        // Map Controls
                        mapControlsStack
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 34) // Account for home indicator
                }
            }
            .navigationBarHidden(true)
        }
        .onMapCameraChange(frequency: .continuous) { context in
            currentRegion = context.region
        }
        .sheet(item: $selectedIncident) { incident in
            FireIncidentDetailView(incident: incident)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLegend) {
            MapLegendView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .searchable(text: $searchText, isPresented: $showSearch, prompt: "Search fires by name or location")
        .task { dataService.start() }
    }
    
    // MARK: - UI Components
    
    private var topControlsBar: some View {
                HStack {
            // Search Toggle
            Button(action: { showSearch.toggle() }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(.thinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .accessibilityLabel("Search fires")
            
            Spacer()
            
            // Fire Count Badge
            if !filteredIncidents.isEmpty {
                FireCountBadge(count: filteredIncidents.count, activeCount: filteredIncidents.filter(\.isActive).count)
                }
                
                        Spacer()
                
            // Map Style Toggle
            Button(action: toggleMapStyle) {
                Image(systemName: mapStyle == .standard ? "map" : "globe")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(.thinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .accessibilityLabel("Change map style")
        }
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }
            
    private var legendButton: some View {
        Button(action: { showLegend = true }) {
                HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("Legend")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            .background(.thinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .accessibilityLabel("Show map legend")
    }
    
    private var mapControlsStack: some View {
        VStack(spacing: 12) {
            // Zoom Controls
            VStack(spacing: 2) {
                MapControlButton(
                    systemName: "plus",
                    action: zoomIn,
                    accessibilityLabel: "Zoom in"
                )
                
                Divider()
                    .frame(width: 20)
                    .background(.tertiary)
                
                MapControlButton(
                    systemName: "minus",
                    action: zoomOut,
                    accessibilityLabel: "Zoom out"
                )
            }
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Location Button
            MapControlButton(
                systemName: locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways ? "location.fill" : "location",
                action: recenterToUser,
                accessibilityLabel: "Center on my location"
            )
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Functions
    
    private func selectIncident(_ incident: CALFireIncident) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedIncident = incident
        }
    }
    
    private func toggleMapStyle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            mapStyle = mapStyle == .standard ? .hybrid : .standard
        }
    }
    
    private func flameColor(for incident: CALFireIncident) -> Color {
        if !incident.isActive {
            return .gray
        }
        
        let acres = incident.acresBurned
        if acres > 10000 {
            return .red
        } else {
            return .orange
        }
    }
    

    
    // MARK: - Zoom Functions
    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(currentRegion.span.latitudeDelta * 0.5, 0.01),
            longitudeDelta: max(currentRegion.span.longitudeDelta * 0.5, 0.01)
        )
        currentRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        cameraPosition = .region(currentRegion)
    }
    
    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(currentRegion.span.latitudeDelta * 2.0, 180.0),
            longitudeDelta: min(currentRegion.span.longitudeDelta * 2.0, 360.0)
        )
        currentRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        cameraPosition = .region(currentRegion)
    }

    private func recenterToUser() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let loc = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                )
                withAnimation(.easeInOut(duration: reduceMotion ? 0 : 0.25)) {
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
}

// MARK: - Fire Incident Detail Modal
struct FireIncidentDetailView: View {
    let incident: CALFireIncident
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced background with better visual hierarchy
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.02, blue: 0.01),
                        Color(red: 0.1, green: 0.05, blue: 0.02),
                        Color(red: 0.15, green: 0.08, blue: 0.03),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Enhanced header with better spacing
                        enhancedHeaderSection
                        
                        // Critical status information first
                        criticalStatusSection
                        
                        // Key metrics in cards
                        keyMetricsSection
                        
                        // Detailed information
                        detailedInfoSection
                        
                        // Action buttons
                        actionButtonsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Fire Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.wsOrange)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
    
    // MARK: - Enhanced Modal Sections
    
    private var enhancedHeaderSection: some View {
        VStack(spacing: 20) {
            // Enhanced fire icon with better visual design
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(flameColorForDetail(incident).opacity(0.8), lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "flame.fill")
                    .foregroundColor(flameColorForDetail(incident))
                    .font(.system(size: 40, weight: .semibold))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            }
            
            VStack(spacing: 8) {
                // Fire name with better typography
                Text(incident.name)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 28 : 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                // Location subtitle
                Text(incident.location)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 18 : 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var criticalStatusSection: some View {
        VStack(spacing: 16) {
            // Status badge with better visual hierarchy
            HStack {
                Image(systemName: incident.isActive ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundColor(incident.isActive ? .red : .green)
                    .font(.title2)
                
                Text(incident.statusText.uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(incident.isActive ? .red : .green)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Enhanced containment progress
            ContainmentProgressView(percentage: incident.percentContained)
        }
    }
    
    private var keyMetricsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Acres Burned",
                value: formatAcres(incident.acresBurned),
                icon: "flame.fill",
                color: flameColorForDetail(incident)
            )
            
            MetricCard(
                title: "Started",
                value: formatDate(incident.startedDate),
                icon: "calendar",
                color: .orange
            )
            
            MetricCard(
                title: "County",
                value: incident.county,
                icon: "location.fill",
                color: .blue
            )
            
            MetricCard(
                title: "Containment",
                value: "\(Int(incident.percentContained))%",
                icon: "checkmark.circle.fill",
                color: incident.percentContained >= 100 ? .green : .orange
            )
        }
    }
    
    private var detailedInfoSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Additional Information")
            
            InfoRow(label: "Full Location", value: incident.location)
            InfoRow(label: "Status", value: incident.statusText)
            InfoRow(label: "Date Started", value: incident.startedDate)
            
            if !incident.url.isEmpty {
                Link(destination: URL(string: incident.url) ?? URL(string: "https://example.com")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("View Official Report")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundColor(.wsOrange)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Share functionality
                shareFireInfo()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Fire Information")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.wsOrange, in: RoundedRectangle(cornerRadius: 12))
            }
            
            if incident.isActive {
                Button(action: {
                    // Emergency action
                    callEmergencyServices()
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Emergency Services")
                    }
                    .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatAcres(_ acres: Double) -> String {
        if acres >= 1000 {
            return String(format: "%.1fK", acres / 1000)
        } else {
            return String(format: "%.0f", acres)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    private func shareFireInfo() {
        let text = """
        🔥 \(incident.name)
        📍 \(incident.location)
        🔥 \(Int(incident.acresBurned)) acres burned
        📊 \(Int(incident.percentContained))% contained
        📅 Started: \(incident.startedDate)
        Status: \(incident.statusText)
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func callEmergencyServices() {
        if let url = URL(string: "tel://911") {
            UIApplication.shared.open(url)
        }
    }
    
    private func flameColorForDetail(_ incident: CALFireIncident) -> Color {
        if !incident.isActive {
            return .gray
        }
        
        let acres = incident.acresBurned
        if acres > 10000 {
            return .red
        } else {
            return .orange
        }
    }
    
    // MARK: - Old Sections (to be removed)
    private var statusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: incident.isActive ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundColor(incident.isActive ? .red : .green)
                    .font(.title3)
                
                Text(incident.statusText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(incident.isActive ? .red : .green)
                
                Spacer()
                            }
                            
            // Containment Progress
            VStack(alignment: .leading, spacing: 8) {
                            HStack {
                    Text("Containment")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                                Spacer()
                    Text("\(Int(incident.percentContained))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.wsOrange)
                }
                
                ProgressView(value: incident.percentContained / 100.0)
                    .tint(.wsOrange)
                    .scaleEffect(y: 2)
            }
        }
        .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                    )
            )
    }
            
    // MARK: - Metrics Section
    private var metricsSection: some View {
                        VStack(spacing: 16) {
            HStack {
                Text("Fire Metrics")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Acres Burned
                FireMetricCard(
                    icon: "flame.fill",
                    title: "Acres Burned",
                    value: formatAcres(incident.acresBurned),
                    color: .red
                )
                
                // Intensity Level
                FireMetricCard(
                    icon: "thermometer.high",
                    title: "Intensity",
                    value: intensityText(incident.intensityLevel),
                    color: intensityColor(incident.intensityLevel)
                )
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(spacing: 16) {
                            HStack {
                Text("Location")
                                    .font(.headline)
                                    .foregroundColor(.white)
                Spacer()
                            }
                            
                VStack(spacing: 12) {
                InfoRow(icon: "location.fill", title: "County", value: incident.county)
                InfoRow(icon: "mappin.and.ellipse", title: "Location", value: incident.location)
                InfoRow(icon: "globe", title: "Coordinates", value: "\(String(format: "%.4f", incident.latitude)), \(String(format: "%.4f", incident.longitude))")
            }
            .padding(16)
                    .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                            .overlay(
                        RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
        }
    }
    
    // MARK: - Additional Info Section
    private var additionalInfoSection: some View {
        VStack(spacing: 16) {
                                HStack {
                Text("Additional Information")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
            VStack(spacing: 12) {
                InfoRow(icon: "calendar", title: "Started", value: formatDate(incident.startedDate))
                
                if !incident.url.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.wsOrange)
                            .frame(width: 20)
                        
                        Text("More Info")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Link("View Details", destination: URL(string: incident.url) ?? URL(string: "https://fire.ca.gov")!)
                            .foregroundColor(.wsOrange)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(16)
                            .background(
                                    RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
    
    // MARK: - Helper Functions
    private func flameColorForDetail(_ incident: CALFireIncident) -> Color {
        if !incident.isActive {
            return .gray
        }
        return incident.acresBurned > 10000 ? .red : .orange
    }
    
    private func formatAcres(_ acres: Double) -> String {
        if acres >= 1000 {
            return String(format: "%.1fK", acres / 1000)
        } else {
            return String(format: "%.0f", acres)
        }
    }
    
    private func intensityText(_ level: Int) -> String {
        switch level {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        case 3: return "Extreme"
        default: return "Unknown"
        }
    }
    
    private func intensityColor(_ level: Int) -> Color {
        switch level {
        case 0: return .green
        case 1: return .yellow
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        if dateString.isEmpty {
            return "Unknown"
        }
        
        // Try to parse and format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: String(dateString.prefix(10))) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Supporting Views
struct FireMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                            .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                                    .foregroundColor(.white)
                            
            Text(title)
                                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
                            .background(
                                    RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.6))
                                    .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.wsOrange)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WildfireMapPreview()
}

// Preview-safe static content to avoid network during canvas
private struct WildfireMapPreview: View {
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.25, longitude: -120.0),
            span: MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0)
        )
    )

    private let sample: [CALFireIncident] = [
        CALFireIncident(
            name: "Dangerous Fire",
            acresBurned: 15000, // Red - dangerous/intense
            percentContained: 25,
            isActive: true,
            startedDate: "2025-08-01",
            county: "Mariposa",
            location: "Near Something Rd",
            latitude: 37.7749,
            longitude: -122.4194,
            url: "https://example.com"
        ),
        CALFireIncident(
            name: "Medium Fire",
            acresBurned: 3000, // Orange - active/medium
            percentContained: 50,
            isActive: true,
            startedDate: "2025-08-02",
            county: "Los Angeles",
            location: "Near Sample Town",
            latitude: 34.0522,
            longitude: -118.2437,
            url: "https://example.com"
        ),
        CALFireIncident(
            name: "Small Fire",
            acresBurned: 500, // Yellow - contained/active
            percentContained: 80,
            isActive: true,
            startedDate: "2025-08-03",
            county: "Fresno",
            location: "Near Sample Village",
            latitude: 36.7783,
            longitude: -119.4179,
            url: "https://example.com"
        ),
        CALFireIncident(
            name: "Contained Fire",
            acresBurned: 80, // Gray - inactive
            percentContained: 100,
            isActive: false,
            startedDate: "2025-08-02",
            county: "Sacramento",
            location: "Near Sample Creek",
            latitude: 38.5816,
            longitude: -121.4944,
            url: "https://example.com"
        )
    ]
    
    private func flameColorForPreview(for incident: CALFireIncident) -> Color {
        // If fire is inactive, always gray
        if !incident.isActive {
            return .gray
        }
        
        // For active fires: red for dangerous (>10k acres), orange for everything else
        let acres = incident.acresBurned
        
        if acres > 10000 {
            return .red      // Red - dangerous fires (>10k acres)
        } else {
            return .orange   // Orange - all other active fires
        }
    }
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: [.pan]) {
            ForEach(sample) { i in
                let coord = CLLocationCoordinate2D(latitude: i.latitude, longitude: i.longitude)
                Annotation(i.name, coordinate: coord) {
                    Button(action: {
                        // Preview action - could show alert or do nothing
                    }) {
                        ZStack {
                            // Outer black background circle
                            Circle()
                                .fill(Color.black.opacity(0.8))
                                .frame(width: 36, height: 36)
                            
                            // Inner semi-transparent circle for depth
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 32, height: 32)
                            
                            // Fire icon
                            Image(systemName: "flame.fill")
                                .foregroundColor(flameColorForPreview(for: i))
                                .font(.title2)
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Supporting Views

struct FireMarkerView: View {
    let incident: CALFireIncident
    let isSelected: Bool
    let onTap: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Enhanced marker design with better visual hierarchy
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: isSelected ? 52 : 48, height: isSelected ? 52 : 48)
                .overlay(
                    Circle()
                            .stroke(flameColor.opacity(0.8), lineWidth: 2)
                )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Image(systemName: "flame.fill")
                    .foregroundColor(flameColor)
                    .font(.system(size: isSelected ? 22 : 18, weight: .semibold))
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
        .scaleEffect(reduceMotion ? 1.0 : (isSelected ? 1.1 : 1.0))
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(incident.name), \(incident.statusText), \(Int(incident.percentContained)) percent contained, \(Int(incident.acresBurned)) acres burned")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to view fire details")
    }
    
    private var flameColor: Color {
        if !incident.isActive {
            return .gray
        }
        
        let acres = incident.acresBurned
        if acres > 10000 {
            return .red
            } else {
            return .orange
        }
    }
}

struct MapControlButton: View {
    let systemName: String
    let action: () -> Void
    let accessibilityLabel: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(accessibilityLabel)
        .buttonStyle(PlainButtonStyle())
    }
}

struct FireCountBadge: View {
    let count: Int
    let activeCount: Int
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.system(size: 12, weight: .medium))
            
            VStack(spacing: 1) {
                Text("\(activeCount)")
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 14 : 12, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("active")
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 10 : 8, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if count != activeCount {
                Divider()
                    .frame(height: 20)
                
                VStack(spacing: 1) {
                    Text("\(count - activeCount)")
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 14 : 12, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("contained")
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 10 : 8, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(activeCount) active fires, \(count - activeCount) contained fires")
    }
}

struct MapLegendView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Fire Status Legend")
                                    .font(.headline)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    LegendItem(
                        color: .red,
                        title: "High Risk",
                        description: "Active fires over 10,000 acres"
                    )
                    
                    LegendItem(
                        color: .orange,
                        title: "Active",
                        description: "Active fires under 10,000 acres"
                    )
                    
                    LegendItem(
                        color: .gray,
                        title: "Contained",
                        description: "Inactive or fully contained fires"
                    )
                }
                .padding(.horizontal)
                
                                    Spacer()
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
        }
    }
}

struct LegendItem: View {
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
            Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
