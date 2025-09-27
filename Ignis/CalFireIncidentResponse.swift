//
//  CalFireIncidentResponse.swift
//  Ignis
//
//  Created by Areen Jain on 8/4/25.
//


import Foundation
// MARK: - Cal Fire Models
struct CalFireIncidentResponse: Codable {
    let incidents: [CalFireIncidentData]
}
struct CalFireIncidentData: Codable {
    let id: String
    let name: String
    let county: String
    let acres: String
    let containment: String
    let started: String
    let location: String
    let isActive: Bool
    let latitude: Double?
    let longitude: Double?
    let url: String
    let lastUpdate: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, county, acres, containment, started, location, url
        case isActive = "is_active"
        case latitude = "lat"
        case longitude = "lng"
        case lastUpdate = "last_update"
    }
}
// MARK: - Cal Fire Service
class CalFireService: ObservableObject {
    @Published var incidents: [CALFireIncident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 3 * 60 * 60 // 3 hours in seconds
    
    // Cal Fire API endpoint - switch to official GeoJSON list per request
    private let calFireOfficialAPI = "https://incidents.fire.ca.gov/umbraco/api/IncidentApi/GeoJsonList?inactive=true"
    private let calFireIncidentsURL = "https://www.fire.ca.gov/incidents"
    private let calFireRSSURL = "https://www.fire.ca.gov/rss/rss.xml"
    
    init() {
        startPeriodicUpdates()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func startPeriodicUpdates() {
        fetchCalFireData() // Initial fetch
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.fetchCalFireData()
        }
    }
    
    func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func fetchCalFireData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedIncidents = try await fetchFromMultipleSources()
                await MainActor.run {
                    self.incidents = fetchedIncidents
                    self.isLoading = false
                    self.lastUpdated = Date()
                    print("✅ Cal Fire data updated: \(fetchedIncidents.count) incidents")
                    if fetchedIncidents.isEmpty {
                        print("⚠️ No incidents found - this might be why no fires are showing")
                    } else {
                        print("🔥 Sample incidents: \(fetchedIncidents.prefix(3).map { $0.name })")
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    // Fallback to existing static data if available
                    if self.incidents.isEmpty {
                        print("📝 Using static Cal Fire data as fallback")
                        self.incidents = calFireIncidents // Use existing static data as fallback
                    }
                    print("❌ Cal Fire fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Data Fetching Methods
    
    private func fetchFromMultipleSources() async throws -> [CALFireIncident] {
        // Primary source: Official Cal Fire API (most accurate and up-to-date)
        async let officialResult = fetchFromOfficialCalFireAPI()
        async let rssResult = fetchFromRSSFeed()
        
        // Combine results, prioritizing official API
        let allResults = try await [
            officialResult,
            rssResult
        ].flatMap { $0 }
        
        // Remove duplicates and merge data (prefer official API data)
        let mergedIncidents = mergeAndDeduplicateIncidents(from: allResults)
        return mergedIncidents.sorted { $0.acresBurned > $1.acresBurned }
    }
    
    // MARK: - Official Cal Fire API Method
    private func fetchFromOfficialCalFireAPI() async throws -> [CALFireIncident] {
        guard let url = URL(string: calFireOfficialAPI) else {
            throw CalFireError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        do {
            print("🌐 Requesting Cal Fire API: \(calFireOfficialAPI)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("📊 API Response - Status: \((response as? HTTPURLResponse)?.statusCode ?? 0), Data size: \(data.count) bytes")
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Official Cal Fire API returned non-200 status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return []
            }
            
            // Log first 500 characters of response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                let preview = String(responseString.prefix(500))
                print("📝 API Response preview: \(preview)")
            }
            
            let incidents = try parseOfficialCalFireResponse(data)
            print("🔥 Parsed \(incidents.count) incidents from Official Cal Fire API")
            return incidents
            
        } catch {
            print("⚠️ Official Cal Fire API error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Official Cal Fire API Response Parsing
    private func parseOfficialCalFireResponse(_ data: Data) throws -> [CALFireIncident] {
        // Parse GeoJSON FeatureCollection from the Incidents API
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let features = json["features"] as? [[String: Any]] else {
            throw CalFireError.parsingError
        }

        var incidents: [CALFireIncident] = []
        var filteredOut = 0

        for feature in features {
            guard let props = feature["properties"] as? [String: Any],
                  let geometry = feature["geometry"] as? [String: Any] else { continue }
            if let incident = parseOfficialCalFireFeature(properties: props, geometry: geometry) {
                // Filter fires: keep active fires regardless of start date, or recent fires within 30 days
                if let startStr = props["Started"] as? String ?? props["StartedDateOnly"] as? String,
                   let startDate = parseDateFlexible(startStr) {
                    let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                    let isActive = props["IsActive"] as? Bool ?? true
                    
                    // Keep active fires regardless of start date, or recent fires within 30 days
                    if !isActive && startDate < cutoff {
                        filteredOut += 1
                        continue
                    }
                }
                incidents.append(incident)
            }
        }
        print("✅ Parsed \(incidents.count) incidents (filtered out: \(filteredOut))")
        return incidents
    }
    
    private func parseOfficialCalFireFeature(properties: [String: Any], geometry: [String: Any]) -> CALFireIncident? {
        // Extract data from the official Cal Fire API response
        guard let name = properties["Name"] as? String else { 
            print("⚠️ Feature missing 'Name' property. Available properties: \(properties.keys.sorted())")
            return nil 
        }
        
        let started = properties["Started"] as? String ?? properties["StartedDateOnly"] as? String ?? ""
        
        let acresBurned = properties["AcresBurned"] as? Double ?? 0.0
        let percentContained = properties["PercentContained"] as? Double ?? 0.0
        let isActive = properties["IsActive"] as? Bool ?? true
        let county = properties["County"] as? String ?? "California"
        let location = properties["Location"] as? String ?? county
        let url = properties["Url"] as? String ?? ""
        
        // Extract coordinates from geometry
        var latitude = 0.0
        var longitude = 0.0
        
        if let coordinates = geometry["coordinates"] as? [Double], coordinates.count >= 2 {
            longitude = coordinates[0]
            latitude = coordinates[1]
        }
        
        return CALFireIncident(
            name: name,
            acresBurned: acresBurned,
            percentContained: percentContained,
            isActive: isActive,
            startedDate: started,
            county: county,
            location: location,
            latitude: latitude,
            longitude: longitude,
            url: url
        )
    }
    
    // MARK: - ArcGIS Cal Fire Feature Parsing
    private func parseArcGISCalFireFeature(attributes: [String: Any], feature: [String: Any]) -> CALFireIncident? {
        // Extract data from the ArcGIS REST service response
        guard let name = attributes["FIRE_NAME"] as? String, !name.isEmpty else { 
            print("⚠️ Feature missing 'FIRE_NAME'. Available attributes: \(attributes.keys.sorted())")
            return nil 
        }
        
        // Extract basic fire information
        let acresBurned = (attributes["GIS_ACRES"] as? Double) ?? (attributes["REPORT_AC"] as? Double) ?? 0.0
        let year = attributes["YEAR_"] as? String ?? ""
        let alarmDate = attributes["ALARM_DATE"] as? String ?? ""
        let contDate = attributes["CONT_DATE"] as? String ?? ""
        
        // Determine if fire is active (no containment date means still active)
        let isActive = contDate.isEmpty || contDate == "null"
        let percentContained = isActive ? 0.0 : 100.0 // Simplified - if contained, assume 100%
        
        // Extract geometry for coordinates
        var latitude = 0.0
        var longitude = 0.0
        
        if let geometry = feature["geometry"] as? [String: Any],
           let rings = geometry["rings"] as? [[[Double]]],
           let firstRing = rings.first,
           let firstPoint = firstRing.first,
           firstPoint.count >= 2 {
            // For polygon geometry, use the first point of the first ring
            longitude = firstPoint[0]
            latitude = firstPoint[1]
            
            // Convert from Web Mercator to WGS84 if needed
            if let spatialRef = geometry["spatialReference"] as? [String: Any],
               let wkid = spatialRef["wkid"] as? Int,
               wkid == 102100 || wkid == 3857 {
                // This is Web Mercator, need to convert to lat/lon
                let (lat, lon) = webMercatorToLatLon(x: longitude, y: latitude)
                latitude = lat
                longitude = lon
            }
        }
        
        // Create URL for the fire
        let url = "https://www.fire.ca.gov/incidents/\(year)/\(name.lowercased().replacingOccurrences(of: " ", with: "-"))-fire/"
        
        // Filter out very old fires (only include fires from current year and last year)
        let currentYear = Calendar.current.component(.year, from: Date())
        if let fireYear = Int(year), fireYear < currentYear - 1 {
            return nil
        }
        
        print("🔥 Parsed fire: \(name) - \(acresBurned) acres, Active: \(isActive)")
        
        return CALFireIncident(
            name: name,
            acresBurned: acresBurned,
            percentContained: percentContained,
            isActive: isActive,
            startedDate: alarmDate,
            county: "California", // ArcGIS data doesn't seem to have county info readily available
            location: "California",
            latitude: latitude,
            longitude: longitude,
            url: url
        )
    }
    
    // Helper function to convert Web Mercator to Lat/Lon
    private func webMercatorToLatLon(x: Double, y: Double) -> (latitude: Double, longitude: Double) {
        let earthRadius = 6378137.0
        let lon = x / earthRadius * 180.0 / Double.pi
        let lat = atan(sinh(y / earthRadius)) * 180.0 / Double.pi
        return (latitude: lat, longitude: lon)
    }
    
    private func parseGISFeature(attributes: [String: Any], geometry: [String: Any]) -> CALFireIncident? {
        // Extract fire data from GIS attributes
        let name = attributes["FIRE_NAME"] as? String ?? "Unknown Fire"
        let acresStr = attributes["ACRES"] as? String ?? attributes["ACRES_BURNED"] as? String ?? "0"
        let containmentStr = attributes["CONTAINMENT"] as? String ?? attributes["PERCENT_CONTAINED"] as? String ?? "0"
        let county = attributes["COUNTY"] as? String ?? "Unknown"
        let started = attributes["START_DATE"] as? String ?? attributes["DATE_STARTED"] as? String ?? ""
        let location = attributes["LOCATION"] as? String ?? county
        let isActive = attributes["STATUS"] as? String != "Contained"
        let url = attributes["URL"] as? String ?? ""
        
        // Extract coordinates from geometry
        var latitude = 0.0
        var longitude = 0.0
        
        if let x = geometry["x"] as? Double, let y = geometry["y"] as? Double {
            longitude = x
            latitude = y
        } else if let rings = geometry["rings"] as? [[[Double]]], 
                  let firstRing = rings.first,
                  let firstPoint = firstRing.first {
            longitude = firstPoint[0]
            latitude = firstPoint[1]
        }
        
        return CALFireIncident(
            name: name,
            acresBurned: parseAcres(acresStr),
            percentContained: parseContainment(containmentStr),
            isActive: isActive,
            startedDate: started,
            county: county,
            location: location,
            latitude: latitude,
            longitude: longitude,
            url: url.isEmpty ? "https://www.fire.ca.gov/incidents" : url
        )
    }
    
    // MARK: - Current Incidents Page Method
    private func fetchFromCurrentIncidentsPage() async throws -> [CALFireIncident] {
        guard let url = URL(string: calFireIncidentsURL) else {
            throw CalFireError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let html = String(data: data, encoding: .utf8) else {
                return []
            }
            
            let incidents = parseCurrentIncidentsHTML(html)
            print("🌐 Fetched \(incidents.count) incidents from Cal Fire current incidents page")
            return incidents
            
        } catch {
            print("⚠️ Cal Fire current incidents error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - RSS Feed Method
    private func fetchFromRSSFeed() async throws -> [CALFireIncident] {
        guard let url = URL(string: calFireRSSURL) else {
            throw CalFireError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let incidents = parseCalFireRSS(data)
            print("📰 Fetched \(incidents.count) incidents from Cal Fire RSS")
            return incidents
            
        } catch {
            print("⚠️ Cal Fire RSS error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Parsing Methods
    
    private func parseCalFireAPIResponse(_ data: Data) throws -> [CALFireIncident] {
        // Try to parse as JSON API response
        do {
            let response = try JSONDecoder().decode(CalFireIncidentResponse.self, from: data)
            return response.incidents.compactMap { convertToCALFireIncident($0) }
        } catch {
            // If structured API fails, try parsing as raw JSON array
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return jsonArray.compactMap { parseIncidentFromJSON($0) }
            }
            throw error
        }
    }
    
    private func parseCalFireHTML(_ html: String) -> [CALFireIncident] {
        var incidents: [CALFireIncident] = []
        
        // Look for incident data in script tags or data attributes (patterns in use in parseIncidentHTML)
        
        // Extract incident blocks (this is a simplified parser)
        let incidentPattern = #"<div[^>]*class=\"[^\"]*incident[^\"]*\"[^>]*>(.*?)</div>"#
        let regex = try? NSRegularExpression(pattern: incidentPattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        
        let range = NSRange(location: 0, length: html.utf16.count)
        regex?.enumerateMatches(in: html, options: [], range: range) { match, _, _ in
            guard let match = match,
                  let range = Range(match.range, in: html) else { return }
            
            let incidentHTML = String(html[range])
            if let incident = parseIncidentHTML(incidentHTML) {
                incidents.append(incident)
            }
        }
        
        return incidents
    }
    
    private func parseIncidentHTML(_ html: String) -> CALFireIncident? {
        // Extract data attributes from HTML
        let name = extractValue(from: html, pattern: #"data-name=\"([^\"]+)\""#) ?? "Unknown Fire"
        let acresStr = extractValue(from: html, pattern: #"data-acres=\"([^\"]+)\""#) ?? "0"
        let containmentStr = extractValue(from: html, pattern: #"data-containment=\"([^\"]+)\""#) ?? "0"
        let county = extractValue(from: html, pattern: #"data-county=\"([^\"]+)\""#) ?? "Unknown"
        let started = extractValue(from: html, pattern: #"data-started=\"([^\"]+)\""#) ?? ""
        let latStr = extractValue(from: html, pattern: #"data-lat=\"([^\"]+)\""#)
        let lngStr = extractValue(from: html, pattern: #"data-lng=\"([^\"]+)\""#)
        let urlPath = extractValue(from: html, pattern: #"href=\"(/incidents/[^\"]+)\""#)
        
        // Clean and parse numeric values
        let acres = parseAcres(acresStr)
        let containment = parseContainment(containmentStr)
        let latitude = latStr.flatMap { Double($0) } ?? 0.0
        let longitude = lngStr.flatMap { Double($0) } ?? 0.0
        let url = urlPath.map { "https://www.fire.ca.gov\($0)" } ?? ""
        
        return CALFireIncident(
            name: name,
            acresBurned: acres,
            percentContained: containment,
            isActive: containment < 100,
            startedDate: started,
            county: county,
            location: county,
            latitude: latitude,
            longitude: longitude,
            url: url
        )
    }
    
    private func parseCalFireRSS(_ data: Data) -> [CALFireIncident] {
        guard let rssString = String(data: data, encoding: .utf8) else { return [] }
        
        var incidents: [CALFireIncident] = []
        
        // Parse RSS XML for fire incidents
        let itemPattern = #"<item>(.*?)</item>"#
        let regex = try? NSRegularExpression(pattern: itemPattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        
        let range = NSRange(location: 0, length: rssString.utf16.count)
        regex?.enumerateMatches(in: rssString, options: [], range: range) { match, _, _ in
            guard let match = match,
                  let range = Range(match.range, in: rssString) else { return }
            
            let itemXML = String(rssString[range])
            if let incident = parseRSSItem(itemXML) {
                incidents.append(incident)
            }
        }
        
        return incidents
    }
    
    private func parseRSSItem(_ xml: String) -> CALFireIncident? {
        let title = extractValue(from: xml, pattern: #"<title>(.*?)</title>"#) ?? "Unknown Fire"
        let link = extractValue(from: xml, pattern: #"<link>(.*?)</link>"#) ?? ""
        let description = extractValue(from: xml, pattern: #"<description>(.*?)</description>"#) ?? ""
        
        // Extract fire details from title and description
        let name = extractFireName(from: title)
        let acres = extractAcresFromDescription(description)
        let containment = extractContainmentFromDescription(description)
        
        return CALFireIncident(
            name: name,
            acresBurned: acres,
            percentContained: containment,
            isActive: containment < 100,
            startedDate: "",
            county: "California",
            location: "California",
            latitude: 0.0,
            longitude: 0.0,
            url: link
        )
    }
    
    // MARK: - Helper Methods
    
    private func convertToCALFireIncident(_ data: CalFireIncidentData) -> CALFireIncident? {
        let acres = parseAcres(data.acres)
        let containment = parseContainment(data.containment)
        
        return CALFireIncident(
            name: data.name,
            acresBurned: acres,
            percentContained: containment,
            isActive: data.isActive,
            startedDate: data.started,
            county: data.county,
            location: data.location,
            latitude: data.latitude ?? 0.0,
            longitude: data.longitude ?? 0.0,
            url: data.url.isEmpty ? "" : data.url
        )
    }
    
    private func parseIncidentFromJSON(_ json: [String: Any]) -> CALFireIncident? {
        guard let name = json["name"] as? String else { return nil }
        
        let acresStr = json["acres"] as? String ?? "0"
        let containmentStr = json["containment"] as? String ?? "0"
        let county = json["county"] as? String ?? "Unknown"
        let started = json["started"] as? String ?? ""
        let location = json["location"] as? String ?? county
        let latitude = json["latitude"] as? Double ?? 0.0
        let longitude = json["longitude"] as? Double ?? 0.0
        let url = json["url"] as? String ?? ""
        let isActive = json["is_active"] as? Bool ?? true
        
        return CALFireIncident(
            name: name,
            acresBurned: parseAcres(acresStr),
            percentContained: parseContainment(containmentStr),
            isActive: isActive,
            startedDate: started,
            county: county,
            location: location,
            latitude: latitude,
            longitude: longitude,
            url: url
        )
    }
    
    private func extractValue(from text: String, pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, options: [], range: range),
           let valueRange = Range(match.range(at: 1), in: text) {
            return String(text[valueRange])
        }
        return nil
    }
    
    private func parseAcres(_ acresStr: String) -> Double {
        let cleanStr = acresStr.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " acres", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleanStr) ?? 0.0
    }
    
    private func parseContainment(_ containmentStr: String) -> Double {
        let cleanStr = containmentStr.replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleanStr) ?? 0.0
    }
    
    private func extractFireName(from title: String) -> String {
        // Extract fire name from RSS title
        if let range = title.range(of: " Fire") {
            let endIndex = title.index(range.upperBound, offsetBy: 0)
            return String(title[..<endIndex])
        }
        return title.components(separatedBy: " - ").first ?? title
    }
    
    private func extractAcresFromDescription(_ description: String) -> Double {
        let pattern = #"(\d+,?\d*)\s*acres?"#
        if let match = extractValue(from: description, pattern: pattern) {
            return parseAcres(match)
        }
        return 0.0
    }
    
    private func extractContainmentFromDescription(_ description: String) -> Double {
        let pattern = #"(\d+)%\s*contain"#
        if let match = extractValue(from: description, pattern: pattern) {
            return Double(match) ?? 0.0
        }
        return 0.0
    }
    
    private func parseCurrentIncidentsHTML(_ html: String) -> [CALFireIncident] {
        var incidents: [CALFireIncident] = []
        
        // Look for incident links in the current incidents page
        let linkPattern = #"<a[^>]*href=\"(/incidents/[^\"]+)\"[^>]*>([^<]+)</a>"#
        let regex = try? NSRegularExpression(pattern: linkPattern, options: [.caseInsensitive])
        
        let range = NSRange(location: 0, length: html.utf16.count)
        regex?.enumerateMatches(in: html, options: [], range: range) { match, _, _ in
            guard let match = match,
                  let urlRange = Range(match.range(at: 1), in: html),
                  let nameRange = Range(match.range(at: 2), in: html) else { return }
            
            let incidentURL = "https://www.fire.ca.gov" + String(html[urlRange])
            let incidentName = String(html[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract basic info from the name/URL if possible
            let incident = CALFireIncident(
                name: incidentName,
                acresBurned: 0.0, // Will be updated from other sources
                percentContained: 0.0, // Will be updated from other sources
                isActive: true,
                startedDate: "",
                county: "California",
                location: "California",
                latitude: 0.0,
                longitude: 0.0,
                url: incidentURL
            )
            
            incidents.append(incident)
        }
        
        return incidents
    }
    
    private func mergeAndDeduplicateIncidents(from incidents: [CALFireIncident]) -> [CALFireIncident] {
        var incidentMap: [String: CALFireIncident] = [:]
        
        for incident in incidents {
            let normalizedName = incident.name.lowercased()
                .replacingOccurrences(of: " fire", with: "")
                .replacingOccurrences(of: " complex", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let existing = incidentMap[normalizedName] {
                // Merge data, preferring more complete/recent information
                let merged = CALFireIncident(
                    name: existing.name.isEmpty ? incident.name : existing.name,
                    acresBurned: max(existing.acresBurned, incident.acresBurned),
                    percentContained: max(existing.percentContained, incident.percentContained), // Use higher containment
                    isActive: existing.isActive || incident.isActive,
                    startedDate: existing.startedDate.isEmpty ? incident.startedDate : existing.startedDate,
                    county: existing.county.isEmpty ? incident.county : existing.county,
                    location: existing.location.isEmpty ? incident.location : existing.location,
                    latitude: existing.latitude == 0.0 ? incident.latitude : existing.latitude,
                    longitude: existing.longitude == 0.0 ? incident.longitude : existing.longitude,
                    url: existing.url.isEmpty ? incident.url : existing.url
                )
                incidentMap[normalizedName] = merged
            } else {
                incidentMap[normalizedName] = incident
            }
        }
        
        return Array(incidentMap.values)
    }
    
    private func isFireWithinLast14Days(startDate: String) -> Bool {
        // Parse the date string from Cal Fire API (format: "2025-08-04T12:27:50Z" or "2025-08-04")
        let dateFormatter = DateFormatter()
        
        // Try ISO 8601 format first
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var fireStartDate = dateFormatter.date(from: startDate)
        
        // If that fails, try date-only format
        if fireStartDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            fireStartDate = dateFormatter.date(from: startDate)
        }
        
        guard let startDate = fireStartDate else {
            // If we can't parse the date, include the fire to be safe
            return true
        }
        
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        return startDate >= fourteenDaysAgo
    }
    
    private func removeDuplicates(from incidents: [CALFireIncident]) -> [CALFireIncident] {
        var uniqueIncidents: [CALFireIncident] = []
        var seenNames: Set<String> = []
        
        for incident in incidents {
            let normalizedName = incident.name.lowercased().trimmingCharacters(in: .whitespaces)
            if !seenNames.contains(normalizedName) {
                seenNames.insert(normalizedName)
                uniqueIncidents.append(incident)
            }
        }
        
        return uniqueIncidents
    }
}
// MARK: - Error Types
enum CalFireError: Error, LocalizedError {
    case invalidURL
    case noData
    case parsingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Cal Fire URL"
        case .noData:
            return "No Cal Fire data available"
        case .parsingError:
            return "Failed to parse Cal Fire data"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
// MARK: - URLSession Extension
extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: CalFireError.noData)
                }
            }
            task.resume()
        }
    }
}

// MARK: - Helpers
private func parseDateFlexible(_ raw: String) -> Date? {
    if raw.isEmpty { return nil }
    // Try ISO8601
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = iso.date(from: raw) { return d }
    iso.formatOptions = [.withInternetDateTime]
    if let d = iso.date(from: raw) { return d }
    // Try yyyy-MM-dd
    let df = DateFormatter()
    df.calendar = Calendar(identifier: .gregorian)
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    if let d = df.date(from: raw) { return d }
    return nil
}


