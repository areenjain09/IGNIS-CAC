import Foundation
import Combine

// MARK: - NASA FIRMS Fire Point Data Model
struct NASAFirePoint: Identifiable, Codable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let brightness: Double
    let scan: Double
    let track: Double
    let acq_date: String
    let acq_time: String
    let satellite: String
    let instrument: String
    let confidence: String
    let version: String
    let bright_t31: Double
    let frp: Double // Fire Radiative Power
    let daynight: String
    
    // Computed properties for easier use
    var acquisitionDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: acq_date)
    }
    
    var isHighConfidence: Bool {
        return confidence == "h" || confidence == "high"
    }
    
    var isDaytime: Bool {
        return daynight == "D"
    }
    
    // Fire intensity based on FRP (Fire Radiative Power)
    var intensityLevel: Int {
        if frp > 100 { return 3 } // Very high
        else if frp > 50 { return 2 } // High
        else if frp > 20 { return 1 } // Medium
        else { return 0 } // Low
    }
}

// MARK: - NASA FIRMS Statistics
struct NASAFireStatistics {
    let totalFirePoints: Int
    let activeFiresLast24Hours: Int
    let highConfidenceFiresLast24Hours: Int
    let totalFireRadiativePower: Double
    let averageFireRadiativePower: Double
    let lastUpdated: Date
    
    // Computed properties for display
    var formattedTotalFRP: String {
        if totalFireRadiativePower > 1000000 {
            return String(format: "%.1fM MW", totalFireRadiativePower / 1000000)
        } else if totalFireRadiativePower > 1000 {
            return String(format: "%.1fK MW", totalFireRadiativePower / 1000)
        } else {
            return String(format: "%.0f MW", totalFireRadiativePower)
        }
    }
    
    var formattedAverageFRP: String {
        return String(format: "%.1f MW", averageFireRadiativePower)
    }
}

// MARK: - NASA FIRMS Service
class NASAFIRMSService: ObservableObject {
    @Published var firePoints: [NASAFirePoint] = []
    @Published var statistics: NASAFireStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let apiKey = "987c3980631b10eeed3d7623e0ce8167"
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 3 * 60 * 60 // 3 hours
    
    // NASA FIRMS API endpoints
    private let baseURL = "https://firms.modaps.eosdis.nasa.gov/api/area/csv"
    
    init() {
        startPeriodicUpdates()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func startPeriodicUpdates() {
        fetchFireData() // Initial fetch
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.fetchFireData()
        }
    }
    
    func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func fetchFireData() {
        Task {
            await fetchUSAFireData()
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func fetchUSAFireData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get fire data for the entire USA using coordinate bounding box
            // USA bounding box: west, south, east, north format
            let usaData = try await fetchFireDataForBoundingBox(
                source: "VIIRS_SNPP_NRT",
                west: -125.0,
                south: 20.0,
                east: -66.0,
                north: 50.0,
                dayRange: 7
            )
            
            // Combine all data
            let allFirePoints = usaData
            
            // Update published properties
            self.firePoints = allFirePoints
            self.statistics = calculateStatistics(from: allFirePoints)
            self.lastUpdated = Date()
            
            print("🛰️ NASA FIRMS: Fetched \(allFirePoints.count) fire points for USA")
            
        } catch {
            self.errorMessage = "Failed to fetch fire data: \(error.localizedDescription)"
            print("❌ NASA FIRMS error: \(error)")
        }
        
        isLoading = false
    }
    
    private func fetchFireDataForBoundingBox(source: String, west: Double, south: Double, east: Double, north: Double, dayRange: Int) async throws -> [NASAFirePoint] {
        // Build URL for NASA FIRMS API using bounding box
        // Format: https://firms.modaps.eosdis.nasa.gov/api/area/csv/{api_key}/{source}/{west},{south},{east},{north}/{dayrange}
        let bboxString = "\(west),\(south),\(east),\(north)"
        let urlString = "\(baseURL)/\(apiKey)/\(source)/\(bboxString)/\(dayRange)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        print("🌐 Requesting NASA FIRMS: \(urlString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check response status
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 NASA FIRMS Response: \(httpResponse.statusCode)")
            print("📡 Response Data Length: \(data.count) bytes")
            
            if httpResponse.statusCode != 200 {
                // Print response data for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Response content: \(responseString)")
                }
                throw URLError(.badServerResponse)
            }
        }
        
        // Parse CSV data
        let csvString = String(data: data, encoding: .utf8) ?? ""
        print("📊 CSV Response (first 500 chars): \(String(csvString.prefix(500)))")
        return parseCSVFireData(csvString)
    }
    
    private func parseCSVFireData(_ csvString: String) -> [NASAFirePoint] {
        let lines = csvString.components(separatedBy: .newlines)
        print("📊 Total lines in CSV: \(lines.count)")
        
        guard lines.count > 1 else { 
            print("❌ CSV has no data lines")
            return [] 
        }
        
        // Print header to understand format
        if let header = lines.first {
            print("📋 CSV Header: \(header)")
        }
        
        // Skip header line
        let dataLines = Array(lines.dropFirst())
        
        var firePoints: [NASAFirePoint] = []
        var parseErrors = 0
        
        for (index, line) in dataLines.enumerated() {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            let columns = line.components(separatedBy: ",")
            if columns.count != 14 {
                parseErrors += 1
                if index < 3 { // Print first few errors for debugging
                    print("⚠️ Line \(index + 2) has only \(columns.count) columns: \(line)")
                }
                continue
            }
            
            // Parse CSV columns according to NASA FIRMS format
            guard let latitude = Double(columns[0]),
                  let longitude = Double(columns[1]),
                  let brightness = Double(columns[2]), // bright_ti4
                  let scan = Double(columns[3]),
                  let track = Double(columns[4]),
                  let bright_t31 = Double(columns[11]), // bright_ti5
                  let frp = Double(columns[12]) else {
                parseErrors += 1
                if index < 3 { // Print first few errors for debugging
                    print("⚠️ Line \(index + 2) parse error: \(line)")
                }
                continue
            }
            
            let firePoint = NASAFirePoint(
                latitude: latitude,
                longitude: longitude,
                brightness: brightness,
                scan: scan,
                track: track,
                acq_date: columns[5],
                acq_time: columns[6],
                satellite: columns[7],
                instrument: columns[8],
                confidence: columns[9],
                version: columns[10],
                bright_t31: bright_t31,
                frp: frp,
                daynight: columns[13]
            )
            
            firePoints.append(firePoint)
        }
        
        print("🔥 Parsed \(firePoints.count) fire points from CSV (\(parseErrors) parse errors)")
        if firePoints.count > 0 {
            print("📍 Sample fire point: lat=\(firePoints[0].latitude), lon=\(firePoints[0].longitude), frp=\(firePoints[0].frp)")
        }
        return firePoints
    }
    
    private func calculateStatistics(from firePoints: [NASAFirePoint]) -> NASAFireStatistics {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        
        // Filter for last 24 hours
        let recentFires = firePoints.filter { firePoint in
            guard let acqDate = firePoint.acquisitionDate else { return false }
            return acqDate >= yesterday
        }
        
        let highConfidenceFires = recentFires.filter { $0.isHighConfidence }
        let totalFRP = firePoints.reduce(0) { $0 + $1.frp }
        let averageFRP = firePoints.isEmpty ? 0 : totalFRP / Double(firePoints.count)
        
        return NASAFireStatistics(
            totalFirePoints: firePoints.count,
            activeFiresLast24Hours: recentFires.count,
            highConfidenceFiresLast24Hours: highConfidenceFires.count,
            totalFireRadiativePower: totalFRP,
            averageFireRadiativePower: averageFRP,
            lastUpdated: now
        )
    }
}

// MARK: - Error Types
enum NASAFIRMSError: Error, LocalizedError {
    case invalidURL
    case noData
    case parseError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid NASA FIRMS URL"
        case .noData:
            return "No fire data received"
        case .parseError:
            return "Failed to parse fire data"
        case .apiError(let message):
            return "NASA FIRMS API error: \(message)"
        }
    }
}
