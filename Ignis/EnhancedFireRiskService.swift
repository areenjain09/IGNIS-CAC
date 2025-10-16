//
//  EnhancedFireRiskService.swift
//  Ignis - Production Enhanced Ensemble Model (94% Accuracy)
//
//  Created by Areen Jain on 8/4/25.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Enhanced Ensemble API Models

struct EnhancedPredictionRequest: Codable {
    let areas: [EnhancedGeographicArea]
    let fireIncidents: [EnhancedFireIncident]
    
    enum CodingKeys: String, CodingKey {
        case areas, fireIncidents = "fire_incidents"
    }
}

struct EnhancedGeographicArea: Codable {
    let name: String
    let displayName: String
    let center: EnhancedCoordinate
    let population: Int
    let areaType: String
    
    enum CodingKeys: String, CodingKey {
        case name, displayName = "display_name", center, population, areaType = "area_type"
    }
}

struct EnhancedCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct EnhancedFireIncident: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let acresBurned: Double
    let percentContained: Double
    let isActive: Bool
    let started: String
    
    enum CodingKeys: String, CodingKey {
        case name, latitude, longitude
        case acresBurned = "acres_burned"
        case percentContained = "percent_contained"
        case isActive = "is_active"
        case started
    }
}

struct EnhancedPredictionResponse: Codable {
    let predictions: [EnhancedRiskPrediction]
    let modelInfo: ModelInfo
    let processingTimeMs: Double
    let weatherSource: String
    
    enum CodingKeys: String, CodingKey {
        case predictions
        case modelInfo = "model_info"
        case processingTimeMs = "processing_time_ms"
        case weatherSource = "weather_source"
    }
}

struct ModelInfo: Codable {
    let type: String
    let accuracy: String
    let components: String
    let features: String
}

struct EnhancedRiskPrediction: Codable {
    let areaName: String
    let riskLevel: String
    let riskScore: Double
    let riskPercentage: Int
    let confidence: Double
    let weatherImpact: String
    let nearbyFires: [EnhancedNearbyFire]
    let topRiskFactors: [APIRiskFactor]
    let evacuationRecommendation: String
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case areaName = "area_name"
        case riskLevel = "risk_level"
        case riskScore = "risk_score"
        case riskPercentage = "risk_percentage"
        case confidence
        case weatherImpact = "weather_impact"
        case nearbyFires = "nearby_fires"
        case topRiskFactors = "top_risk_factors"
        case evacuationRecommendation = "evacuation_recommendation"
        case lastUpdated = "last_updated"
    }
}

struct EnhancedNearbyFire: Codable {
    let name: String
    let distanceKm: Double
    let acresBurned: Double
    let percentContained: Double
    let threatLevel: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case distanceKm = "distance_km"
        case acresBurned = "acres_burned"
        case percentContained = "percent_contained"
        case threatLevel = "threat_level"
    }
}

struct APIRiskFactor: Codable {
    let factor: String
    let contribution: Double
    let value: Double
}

// MARK: - Enhanced Fire Risk Service

class EnhancedFireRiskService: ObservableObject {
    static let shared = EnhancedFireRiskService()
    
    @Published var predictions: [AreaFireRiskPrediction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var modelInfo: ModelInfo?
    @Published var loadingProgress: Double = 0.0
    @Published var loadingStatus: String = ""
    
    // Personal prediction support
    @Published var currentPrediction: AreaFireRiskPrediction?
    
    private let apiBaseUrl = "http://192.168.86.24:8000"
    private let batchSize = 25 // Process areas in batches for better performance
    
    // Dependencies
    private let fireDataService = FireDataService.shared
    private let locationManager = LocationManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
        fetchModelInfo()
    }
    
    private func setupBindings() {
        // Trigger updates when fire data changes
        fireDataService.$calFireIncidents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.calculateAreaRisks() }
            }
            .store(in: &cancellables)
    }
    
    private func fetchModelInfo() {
        Task {
            do {
                guard let url = URL(string: "\(apiBaseUrl)/model/info") else { return }
                let (data, _) = try await URLSession.shared.data(from: url)
                let modelInfo = try JSONDecoder().decode(ModelInfo.self, from: data)
                
                await MainActor.run {
                    self.modelInfo = modelInfo
                }
            } catch {
                print("Failed to fetch model info: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    func calculateAreaRisks() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            loadingProgress = 0.0
            loadingStatus = "Starting statewide fire risk analysis..."
            predictions = [] // Clear existing predictions
        }
        
        do {
            let allPredictions = try await processAreasInBatches()
            
            await MainActor.run {
                self.predictions = allPredictions
                self.lastUpdated = Date()
                self.isLoading = false
                self.loadingProgress = 1.0
                self.loadingStatus = "Complete: \(allPredictions.count) areas analyzed"
            }
        } catch {
            await MainActor.run {
                // Provide more user-friendly error messages
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .cannotConnectToHost, .notConnectedToInternet:
                        self.errorMessage = "Cannot connect to fire risk service. Please check your internet connection and try again."
                    case .timedOut:
                        self.errorMessage = "Fire risk service is taking too long to respond. Please try again later."
                    default:
                        self.errorMessage = "Network error: \(urlError.localizedDescription)"
                    }
                } else {
                    self.errorMessage = "Enhanced prediction failed: \(error.localizedDescription)"
                }
                self.isLoading = false
                self.loadingProgress = 0.0
                self.loadingStatus = "Error occurred"
                print("Enhanced API Error: \(error)")
            }
        }
    }
    
    private func processAreasInBatches() async throws -> [AreaFireRiskPrediction] {
        // Use smart loading: priority areas first, then comprehensive coverage
        let priorityAreas = GeographicAreasData.priorityAreas
        let allOtherAreas = GeographicAreasData.allAreas.filter { area in
            !priorityAreas.contains { priority in priority.name == area.name }
        }
        
        var allPredictions: [AreaFireRiskPrediction] = []
        
        // Phase 1: Load priority areas first for immediate display
        await MainActor.run {
            self.loadingStatus = "Loading priority areas (\(priorityAreas.count) areas)..."
            self.loadingProgress = 0.1
        }
        
        let priorityBatches = priorityAreas.chunked(into: batchSize)
        for (batchIndex, batch) in priorityBatches.enumerated() {
            let batchPredictions = try await callEnhancedAPIForBatch(areas: batch)
            allPredictions.append(contentsOf: batchPredictions)
            
            await MainActor.run {
                self.predictions = allPredictions
                self.loadingProgress = 0.1 + (0.2 * Double(batchIndex + 1) / Double(priorityBatches.count))
            }
        }
        
        // Phase 2: Load comprehensive coverage
        let totalAreas = priorityAreas.count + allOtherAreas.count
        let otherBatches = allOtherAreas.chunked(into: batchSize)
        
        await MainActor.run {
            self.loadingStatus = "Expanding to comprehensive statewide coverage (\(totalAreas) total areas)..."
        }
        
        for (batchIndex, batch) in otherBatches.enumerated() {
            await MainActor.run {
                let overallProgress = 0.3 + (0.7 * Double(batchIndex) / Double(otherBatches.count))
                self.loadingProgress = overallProgress
                self.loadingStatus = "Processing comprehensive coverage batch \(batchIndex + 1) of \(otherBatches.count) (\(batch.count) areas)..."
            }
            
            do {
                let batchPredictions = try await callEnhancedAPIForBatch(areas: batch)
                allPredictions.append(contentsOf: batchPredictions)
                
                // Update UI with partial results for progressive loading
                await MainActor.run {
                    self.predictions = allPredictions
                }
                
                // Small delay to prevent overwhelming the API
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
            } catch {
                print("Comprehensive batch \(batchIndex + 1) failed: \(error)")
                // Continue with other batches even if one fails
            }
        }
        
        return allPredictions
    }
    
    func getRiskForArea(named areaName: String) -> AreaFireRiskPrediction? {
        return predictions.first { $0.area.name.lowercased() == areaName.lowercased() }
    }
    
    func getHighRiskAreas() -> [AreaFireRiskPrediction] {
        return predictions.filter { $0.riskLevel == .high || $0.riskLevel == .extreme }
    }
    
    func predictFireRiskForCurrentLocation() async -> AreaFireRiskPrediction? {
        guard let userLocation = locationManager.location else {
            await MainActor.run {
                self.errorMessage = "Location not available"
            }
            return nil
        }
        
        // Find the closest predefined area to the user's location (from comprehensive dataset)
        let closestArea = GeographicAreasData.allAreas.min { area1, area2 in
            let distance1 = userLocation.distance(from: CLLocation(latitude: area1.center.latitude, longitude: area1.center.longitude))
            let distance2 = userLocation.distance(from: CLLocation(latitude: area2.center.latitude, longitude: area2.center.longitude))
            return distance1 < distance2
        }
        
        guard let area = closestArea else { return nil }
        
        // Trigger area risk calculation if not already done
        if predictions.isEmpty {
            await calculateAreaRisks()
        }
        
        // Find the prediction for the closest area
        let prediction = predictions.first { $0.area.name == area.name }
        
        await MainActor.run {
            self.currentPrediction = prediction
        }
        
        return prediction
    }
    
    // MARK: - Private Methods
    
    private func callEnhancedAPIForBatch(areas: [GeographicArea]) async throws -> [AreaFireRiskPrediction] {
        guard let url = URL(string: "\(apiBaseUrl)/predict") else {
            throw URLError(.badURL)
        }
        
        // Prepare request data for this batch of areas
        let areaData = areas.map { area in
            EnhancedGeographicArea(
                name: area.name,
                displayName: area.displayName,
                center: EnhancedCoordinate(
                    latitude: area.center.latitude,
                    longitude: area.center.longitude
                ),
                population: area.population,
                areaType: mapToAreaType(area.areaType.rawValue)
            )
        }
        
        let fireIncidents = fireDataService.calFireIncidents.map { fire in
            EnhancedFireIncident(
                name: fire.name,
                latitude: fire.latitude,
                longitude: fire.longitude,
                acresBurned: fire.acresBurned,
                percentContained: fire.percentContained,
                isActive: fire.isActive,
                started: ISO8601DateFormatter().string(from: Date()) // Use current date as default
            )
        }
        
        let requestData = EnhancedPredictionRequest(areas: areaData, fireIncidents: fireIncidents)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            let userFriendlyMessage: String
            switch httpResponse.statusCode {
            case 500:
                userFriendlyMessage = "Fire risk service is temporarily unavailable. Please try again later."
            case 503:
                userFriendlyMessage = "Fire risk service is under maintenance. Please try again later."
            case 429:
                userFriendlyMessage = "Too many requests. Please wait a moment and try again."
            default:
                userFriendlyMessage = "Fire risk service error (\(httpResponse.statusCode)). Please try again later."
            }
            throw NSError(domain: "EnhancedFireRiskService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: userFriendlyMessage])
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(EnhancedPredictionResponse.self, from: data)
        
        // Update model info
        await MainActor.run {
            self.modelInfo = apiResponse.modelInfo
        }
        
        // Convert to AreaFireRiskPrediction objects
        return apiResponse.predictions.compactMap { convertToAreaPrediction($0) }
    }
    
    private func convertToAreaPrediction(_ apiPrediction: EnhancedRiskPrediction) -> AreaFireRiskPrediction? {
        guard let area = GeographicAreasData.allAreas.first(where: { $0.name.lowercased() == apiPrediction.areaName.lowercased() }) else {
            return nil
        }
        
        let riskLevel = FireRiskLevel(rawValue: apiPrediction.riskLevel) ?? .low
        
        // Convert nearby fires
        let nearbyFires = apiPrediction.nearbyFires.map { fire in
            NearbyFireInfo(
                name: fire.name,
                distance: fire.distanceKm,
                acres: fire.acresBurned,
                containment: fire.percentContained,
                isActive: fire.threatLevel != "Low"
            )
        }
        
        // Convert risk factors
        let riskFactors = apiPrediction.topRiskFactors.map { factor in
            RiskFactor(
                name: factor.factor,
                impact: factor.contribution,
                description: formatRiskFactorDescription(factor),
                weight: 1.0 // Weight not provided by API
            )
        }
        
        // Parse last updated date
        let lastUpdated = ISO8601DateFormatter().date(from: apiPrediction.lastUpdated) ?? Date()
        
        return AreaFireRiskPrediction(
            area: area,
            riskLevel: riskLevel,
            riskScore: apiPrediction.riskScore,
            confidence: apiPrediction.confidence,
            factors: riskFactors,
            nearbyFires: nearbyFires,
            weatherImpact: apiPrediction.weatherImpact,
            evacuationRoutes: extractEvacuationRoutes(from: apiPrediction.evacuationRecommendation),
            shelterCount: 0, // Not provided by API
            lastUpdated: lastUpdated
        )
    }
    
    private func mapToAreaType(_ vegetationType: String) -> String {
        switch vegetationType.lowercased() {
        case "urban":
            return "Urban"
        case "chaparral", "forest":
            return "Wildland"
        default:
            return "Wildland-Urban Interface"
        }
    }
    
    private func formatRiskFactorDescription(_ factor: APIRiskFactor) -> String {
        return "\(factor.factor): \(String(format: "%.2f", factor.value)) (contribution: \(String(format: "%.1f%%", factor.contribution * 100)))"
    }
    
    private func extractEvacuationRoutes(from recommendation: String) -> [String] {
        // Simple extraction - in real implementation, this would be more sophisticated
        if recommendation.contains("evacuation") {
            return ["Primary evacuation routes", "Secondary routes available"]
        }
        return []
    }
}

// MARK: - Extensions

extension FireRiskLevel {
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "low":
            self = .low
        case "moderate":
            self = .moderate
        case "high":
            self = .high
        case "extreme":
            self = .extreme
        default:
            return nil
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
