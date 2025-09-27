//
//  LocationManager.swift
//  Ignis
//
//  Created by Areen Jain on 7/20/25.
//

import Foundation
import CoreLocation
import SwiftUI
// import MapKit // temporarily disabled

/// Location manager for handling user location and permissions - Optimized for performance
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    // MARK: - Published Properties
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private var lastLocationUpdate: Date = Date.distantPast
    private let minimumUpdateInterval: TimeInterval = 30.0 // Update every 30 seconds max
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    deinit {
        stopLocationUpdates()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Reduced accuracy for better performance
        locationManager.distanceFilter = 500 // Update every 500 meters (increased from 100)
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .other
        authorizationStatus = locationManager.authorizationStatus
        
        // Request permission immediately if not determined
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startLocationUpdates()
        }
    }
    
    // MARK: - Public Methods
    
    /// Request location permission
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Location access is required to show nearby fires. Please enable in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    /// Start location updates with throttling
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        // Only start if not already updating or if enough time has passed
        let timeSinceLastUpdate = Date().timeIntervalSince(lastLocationUpdate)
        guard timeSinceLastUpdate >= minimumUpdateInterval else {
            return
        }
        
        isLoading = true
        locationManager.startUpdatingLocation()
    }
    
    /// Stop location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }
    
    /// Get user's current location region for map centering
    // func getUserLocationRegion() -> MKCoordinateRegion? { return nil }
    
    /// Calculate distance to a fire incident (by lat/lon)
    func distanceToIncident(lat: Double, lon: Double) -> CLLocationDistance? {
        guard let userLocation = location else { return nil }
        let fireCLLocation = CLLocation(latitude: lat, longitude: lon)
        return userLocation.distance(from: fireCLLocation)
    }
    
    /// Format distance for display
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let kilometers = distance / 1000
            return String(format: "%.1fkm", kilometers)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Throttle location updates
        let timeSinceLastUpdate = Date().timeIntervalSince(lastLocationUpdate)
        guard timeSinceLastUpdate >= minimumUpdateInterval else {
            return
        }
        
        // Validate location accuracy
        guard location.horizontalAccuracy <= 1000 else { // Accept locations within 1km accuracy
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.location = location
            self.lastLocationUpdate = Date()
            self.isLoading = false
            self.errorMessage = nil
            
            // Stop updates after getting a good location to save battery
            if location.horizontalAccuracy <= 100 {
                self.stopLocationUpdates()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            // Handle specific location errors
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.errorMessage = "Location access denied. Please enable in Settings."
                case .locationUnknown:
                    self.errorMessage = "Unable to determine location. Please try again."
                case .network:
                    self.errorMessage = "Network error. Please check your connection."
                default:
                    self.errorMessage = "Location error: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "Location error: \(error.localizedDescription)"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
            case .denied, .restricted:
                self.errorMessage = "Location access denied. Please enable in Settings to see nearby fires."
                self.stopLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
    }
}

// MARK: - Location Permission Helper - Optimized

struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("To show you nearby wildfires and provide accurate alerts, we need access to your location.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Enable Location Access") {
                locationManager.requestLocationPermission()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(red: 0.9, green: 0.3, blue: 0.1), Color(red: 0.7, green: 0.1, blue: 0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if let errorMessage = locationManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.01),
                    Color(red: 0.1, green: 0.05, blue: 0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    LocationPermissionView(locationManager: LocationManager.shared)
} 