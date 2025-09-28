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
    
    func fetchSheltersFromMultipleSources(near location: CLLocation) async throws -> [EmergencyShelter] {
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
    func createSampleShelters(near location: CLLocation) -> [EmergencyShelter] {
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
        
        // Create location-specific identifiers based on coordinates
        let locationHash = abs(Int(baseCoordinate.latitude * 1000) + Int(baseCoordinate.longitude * 1000))
        let shelterVariations = [
            ("North", "Community Center", "Main St", ["Food", "Medical Care", "Bedding", "WiFi"]),
            ("South", "High School Gymnasium", "Oak Ave", ["Gymnasium", "Cafeteria", "Restrooms", "Parking"]),
            ("East", "Recreation Center", "Pine Rd", ["Food", "Showers", "Bedding", "Phone Access"]),
            ("West", "Emergency Shelter", "Elm Dr", ["Food", "Medical Care", "Child Care", "WiFi"]),
            ("Central", "Relief Center", "Cedar Blvd", ["Food", "Bedding", "Medical Care", "Pet Area"])
        ]
        
        let variation = shelterVariations[locationHash % shelterVariations.count]
        let streetNumber = 100 + (locationHash % 900)
        
        return [
            EmergencyShelter(
                name: "Red Cross \(variation.0) \(variation.1)",
                address: "\(streetNumber) \(variation.2), Fire Zone \(locationHash % 100)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.02...0.02),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.02...0.02)
                ),
                capacity: "\(400 + (locationHash % 300)) people",
                status: [.open, .limited, .full][locationHash % 3],
                type: .general,
                phone: "1-800-RED-CROSS",
                amenities: variation.3,
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: "Red Cross Pet-Friendly \(variation.1)",
                address: "\(streetNumber + 50) \(variation.2), Safe Zone \(locationHash % 50)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.03...0.01),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.01...0.03)
                ),
                capacity: "\(200 + (locationHash % 200)) people + pets",
                status: [.open, .limited][locationHash % 2],
                type: .pets,
                phone: "1-800-RED-CROSS",
                amenities: ["Pet Care", "Food", "Veterinary Services", "Bedding"],
                lastUpdated: Date()
            )
        ]
    }
    
    private func createFEMASampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let baseCoordinate = location.coordinate
        
        // Create location-specific identifiers
        let locationHash = abs(Int(baseCoordinate.latitude * 1000) + Int(baseCoordinate.longitude * 1000))
        let femaFacilities = [
            ("Disaster Relief Center", "Federal Way"),
            ("Emergency Response Hub", "Government Blvd"),
            ("Crisis Support Center", "FEMA Dr"),
            ("Disaster Recovery Station", "Relief Rd"),
            ("Emergency Operations Center", "Federal Ave")
        ]
        
        let facility = femaFacilities[locationHash % femaFacilities.count]
        let streetNumber = 1000 + (locationHash % 9000)
        
        return [
            EmergencyShelter(
                name: "FEMA \(facility.0)",
                address: "\(streetNumber) \(facility.1), Response Zone \(locationHash % 10)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.03...0.03),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.03...0.03)
                ),
                capacity: "\(800 + (locationHash % 400)) people",
                status: [.open, .limited][locationHash % 2],
                type: .general,
                phone: "1-800-621-FEMA",
                amenities: ["Food", "Medical Care", "Case Management", "Financial Assistance"],
                lastUpdated: Date()
            )
        ]
    }
    
    private func createLocalSampleShelters(near location: CLLocation) -> [EmergencyShelter] {
        let baseCoordinate = location.coordinate
        
        // Create location-specific identifiers
        let locationHash = abs(Int(baseCoordinate.latitude * 1000) + Int(baseCoordinate.longitude * 1000))
        let schoolNames = ["Community High School", "Riverside Elementary", "Mountain View School", "Valley High", "Oakwood Academy"]
        let centerNames = ["Community Center", "Recreation Center", "Civic Center", "Cultural Center", "Activity Center"]
        let streetNames = ["Education Blvd", "School St", "Learning Ave", "Academic Dr", "Campus Rd"]
        let townNames = ["Local Town", "Riverside", "Mountain View", "Valley Springs", "Oakwood"]
        
        let schoolName = schoolNames[locationHash % schoolNames.count]
        let centerName = centerNames[locationHash % centerNames.count]
        let streetName = streetNames[locationHash % streetNames.count]
        let townName = townNames[locationHash % townNames.count]
        let streetNumber = 100 + (locationHash % 900)
        
        return [
            EmergencyShelter(
                name: schoolName,
                address: "\(streetNumber) \(streetName), \(townName) \(locationHash % 100)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.02...0.02),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.02...0.02)
                ),
                capacity: "\(400 + (locationHash % 600)) people",
                status: [.open, .limited, .full][locationHash % 3],
                type: .general,
                phone: "(555) \(100 + (locationHash % 900))-\(1000 + (locationHash % 9000))",
                amenities: ["Gymnasium", "Cafeteria", "Restrooms", "Parking"],
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: centerName,
                address: "\(streetNumber + 200) Community Dr, \(townName) District \(locationHash % 50)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.03...0.01),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.01...0.03)
                ),
                capacity: "\(200 + (locationHash % 400)) people",
                status: [.open, .limited][locationHash % 2],
                type: .family,
                phone: "(555) \(200 + (locationHash % 800))-\(2000 + (locationHash % 8000))",
                amenities: ["Family Rooms", "Kitchen", "Playground", "WiFi"],
                lastUpdated: Date()
            ),
            EmergencyShelter(
                name: "Medical Needs Shelter",
                address: "\(500 + (locationHash % 300)) Healthcare Ave, Medical Zone \(locationHash % 20)",
                coordinates: CLLocationCoordinate2D(
                    latitude: baseCoordinate.latitude + Double.random(in: -0.025...0.025),
                    longitude: baseCoordinate.longitude + Double.random(in: -0.025...0.025)
                ),
                capacity: "\(100 + (locationHash % 150)) people",
                status: [.open, .limited][locationHash % 2],
                type: .medical,
                phone: "(555) \(300 + (locationHash % 700))-\(3000 + (locationHash % 7000))",
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