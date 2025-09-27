import Foundation
import CoreLocation
// import MapKit // temporarily disabled

// MARK: - Shelter Models
struct EmergencyShelter: Identifiable, Codable {
    let id = UUID()
    let name: String
    let address: String
    let coordinates: CLLocationCoordinate2D
    let capacity: String
    let status: ShelterStatus
    let type: ShelterType
    let distance: Double? // in miles
    let phone: String?
    let amenities: [String]
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case name, address, capacity, status, type, phone, amenities, lastUpdated
        case latitude, longitude
    }
    
    init(name: String, address: String, coordinates: CLLocationCoordinate2D, capacity: String, status: ShelterStatus, type: ShelterType, distance: Double? = nil, phone: String? = nil, amenities: [String] = [], lastUpdated: Date = Date()) {
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.capacity = capacity
        self.status = status
        self.type = type
        self.distance = distance
        self.phone = phone
        self.amenities = amenities
        self.lastUpdated = lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        capacity = try container.decode(String.self, forKey: .capacity)
        status = try container.decode(ShelterStatus.self, forKey: .status)
        type = try container.decode(ShelterType.self, forKey: .type)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        amenities = try container.decode([String].self, forKey: .amenities)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        distance = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(capacity, forKey: .capacity)
        try container.encode(status, forKey: .status)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(amenities, forKey: .amenities)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(coordinates.latitude, forKey: .latitude)
        try container.encode(coordinates.longitude, forKey: .longitude)
    }
}

enum ShelterStatus: String, Codable, CaseIterable {
    case open = "Open"
    case closed = "Closed"
    case full = "Full"
    case limited = "Limited Capacity"
    case unknown = "Unknown"
    
    var color: String {
        switch self {
        case .open: return "green"
        case .closed: return "red"
        case .full: return "orange"
        case .limited: return "yellow"
        case .unknown: return "gray"
        }
    }
}

enum ShelterType: String, Codable, CaseIterable {
    case general = "General Population"
    case pets = "Pet-Friendly"
    case medical = "Medical Needs"
    case family = "Family Shelter"
    case temporary = "Temporary"
    
    var icon: String {
        switch self {
        case .general: return "house.fill"
        case .pets: return "pawprint.fill"
        case .medical: return "cross.fill"
        case .family: return "person.3.fill"
        case .temporary: return "tent.fill"
        }
    }
}

// MARK: - Shelter Service
class ShelterService: ObservableObject {
    @Published var shelters: [EmergencyShelter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var userLocation: CLLocation?
    
    init() {
        // Empty init - location will be set from the view
    }
    
    // MARK: - Public Methods
    
    func fetchNearbyShelters(userLocation: CLLocation? = nil) {
        if let location = userLocation {
            self.userLocation = location
        }
        
        guard let userLocation = self.userLocation else {
            errorMessage = "Location not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedShelters = try await fetchSheltersFromMultipleSources(near: userLocation)
                await MainActor.run {
                    self.shelters = fetchedShelters
                    self.isLoading = false
                    self.lastUpdated = Date()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    // Fallback to sample data if API fails
                    self.shelters = self.createSampleShelters(near: userLocation)
                }
            }
        }
    }
    
    // Remove the requestLocationAndFetch method since location is handled by the view
    
    // MARK: - API Integration
    
    private func fetchSheltersFromMultipleSources(near location: CLLocation) async throws -> [EmergencyShelter] {
        // Try multiple sources in parallel
        async let redCrossShelters = fetchRedCrossShelters(near: location)
        async let femaDisasterShelters = fetchFEMADisasterShelters(near: location)
        async let localEmergencyShelters = fetchLocalEmergencyShelters(near: location)
        
        // Combine results from all sources
        let allShelters = try await [
            redCrossShelters,
            femaDisasterShelters,
            localEmergencyShelters
        ].flatMap { $0 }
        
        // Calculate distances and sort by proximity
        let sheltersWithDistance = allShelters.map { shelter -> EmergencyShelter in
            let shelterLocation = CLLocation(latitude: shelter.coordinates.latitude, longitude: shelter.coordinates.longitude)
            let distance = location.distance(from: shelterLocation) * 0.000621371 // Convert to miles
            
            return EmergencyShelter(
                name: shelter.name,
                address: shelter.address,
                coordinates: shelter.coordinates,
                capacity: shelter.capacity,
                status: shelter.status,
                type: shelter.type,
                distance: distance,
                phone: shelter.phone,
                amenities: shelter.amenities,
                lastUpdated: shelter.lastUpdated
            )
        }
        
        // Sort by distance and return closest 20
        return Array(sheltersWithDistance.sorted { $0.distance ?? Double.greatestFiniteMagnitude < $1.distance ?? Double.greatestFiniteMagnitude }.prefix(20))
    }
    
    // MARK: - Red Cross Shelters API
    private func fetchRedCrossShelters(near location: CLLocation) async throws -> [EmergencyShelter] {
        // Red Cross shelter API (this would be a real API endpoint)
        let urlString = "https://www.redcross.org/api/shelters"
        guard URL(string: urlString) != nil else { throw ShelterError.invalidURL }
        
        // For now, return sample data since we don't have direct API access
        // In a real implementation, you would call the actual Red Cross API
        return createRedCrossSampleShelters(near: location)
    }
    
    // MARK: - FEMA Disaster Shelters API
    private func fetchFEMADisasterShelters(near location: CLLocation) async throws -> [EmergencyShelter] {
        // FEMA disaster shelter API
        let urlString = "https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries"
        guard URL(string: urlString) != nil else { throw ShelterError.invalidURL }
        
        // For now, return sample data
        return createFEMASampleShelters(near: location)
    }
    
    // MARK: - Local Emergency Shelters (MapKit Search disabled)
    private func fetchLocalEmergencyShelters(near location: CLLocation) async throws -> [EmergencyShelter] {
        // Map-based local search disabled for previews; return local samples
        return createLocalSampleShelters(near: location)
    }
    
    // MARK: - Sample Data (Fallback)
    private func createSampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let sampleShelters = createRedCrossSampleShelters(near: location) +
                           createFEMASampleShelters(near: location) +
                           createLocalSampleShelters(near: location)
        
        // Calculate distances
        return sampleShelters.map { shelter in
            let shelterLocation = CLLocation(latitude: shelter.coordinates.latitude, longitude: shelter.coordinates.longitude)
            let distance = location.distance(from: shelterLocation) * 0.000621371
            
            return EmergencyShelter(
                name: shelter.name,
                address: shelter.address,
                coordinates: shelter.coordinates,
                capacity: shelter.capacity,
                status: shelter.status,
                type: shelter.type,
                distance: distance,
                phone: shelter.phone,
                amenities: shelter.amenities,
                lastUpdated: shelter.lastUpdated
            )
        }.sorted { $0.distance ?? Double.greatestFiniteMagnitude < $1.distance ?? Double.greatestFiniteMagnitude }
    }
    
    private func createRedCrossSampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let baseCoordinate = location.coordinate
        return [
            EmergencyShelter(
                name: "Red Cross Emergency Shelter",
                address: "1234 Relief Ave, Emergency City",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + 0.01,
                    longitude: baseCoordinate.longitude + 0.01
                ),
                capacity: "500 people",
                status: .open,
                type: .general,
                phone: "1-800-RED-CROSS",
                amenities: ["Food", "Medical Care", "Bedding", "WiFi"],
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: "Red Cross Pet-Friendly Shelter",
                address: "5678 Companion St, Safe Haven",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude - 0.02,
                    longitude: baseCoordinate.longitude + 0.015
                ),
                capacity: "300 people + pets",
                status: .open,
                type: .pets,
                phone: "1-800-RED-CROSS",
                amenities: ["Pet Care", "Food", "Veterinary Services", "Bedding"],
                lastUpdated: Date()
            )
        ]
    }
    
    private func createFEMASampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let baseCoordinate = location.coordinate
        return [
            EmergencyShelter(
                name: "FEMA Disaster Relief Center",
                address: "9876 Federal Way, Disaster Response Zone",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + 0.025,
                    longitude: baseCoordinate.longitude - 0.02
                ),
                capacity: "1000 people",
                status: .open,
                type: .general,
                phone: "1-800-621-3362",
                amenities: ["Food", "Medical Care", "Case Management", "Financial Assistance"],
                lastUpdated: Date()
            )
        ]
    }
    
    private func createLocalSampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let baseCoordinate = location.coordinate
        return [
            EmergencyShelter(
                name: "Community High School",
                address: "123 Education Blvd, Local Town",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude - 0.015,
                    longitude: baseCoordinate.longitude - 0.01
                ),
                capacity: "800 people",
                status: .open,
                type: .general,
                phone: "(555) 123-4567",
                amenities: ["Gymnasium", "Cafeteria", "Restrooms", "Parking"],
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: "Central Community Center",
                address: "456 Community Dr, Neighborhood",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + 0.005,
                    longitude: baseCoordinate.longitude - 0.025
                ),
                capacity: "400 people",
                status: .limited,
                type: .family,
                phone: "(555) 987-6543",
                amenities: ["Family Rooms", "Kitchen", "Playground", "WiFi"],
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: "Medical Needs Shelter",
                address: "789 Healthcare Ave, Medical District",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude - 0.008,
                    longitude: baseCoordinate.longitude + 0.03
                ),
                capacity: "150 people",
                status: .open,
                type: .medical,
                phone: "(555) 456-7890",
                amenities: ["Medical Staff", "Medication Storage", "Accessible Facilities", "Backup Power"],
                lastUpdated: Date()
            )
        ]
    }
}

// MARK: - Error Types
enum ShelterError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case locationNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid shelter service URL"
        case .noData:
            return "No shelter data available"
        case .decodingError:
            return "Failed to decode shelter data"
        case .locationNotAvailable:
            return "Location not available for shelter search"
        }
    }
}