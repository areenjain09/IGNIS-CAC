//
//  InciWebService.swift
//  Ignis
//
//  Created by Areen Jain on 7/20/25.
//
import Foundation
import CoreLocation
struct InciWebIncident: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let containment: Int?
    let status: String?
}
class InciWebService {
    static let shared = InciWebService()
    private let feedURL = URL(string: "https://inciweb.wildfire.gov/feeds/geojson/incidents.geojson")!
    
    func fetchIncidents(completion: @escaping ([InciWebIncident]) -> Void) {
        let task = URLSession.shared.dataTask(with: feedURL) { data, response, error in
            guard let data = data, error == nil else {
                print("InciWeb fetch error: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                let geojson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let features = geojson?["features"] as? [[String: Any]] ?? []
                var incidents: [InciWebIncident] = []
                for feature in features {
                    guard let properties = feature["properties"] as? [String: Any],
                          let geometry = feature["geometry"] as? [String: Any],
                          let coordinates = geometry["coordinates"] as? [Double],
                          coordinates.count >= 2 else { continue }
                    let id = properties["id"] as? String ?? UUID().uuidString
                    let name = properties["name"] as? String ?? "Unknown Fire"
                    let containmentStr = properties["percentContained"] as? String
                    let containment = containmentStr.flatMap { Int($0) }
                    let status = properties["incidentTypeCategory"] as? String
                    let coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
                    let incident = InciWebIncident(id: id, name: name, coordinate: coordinate, containment: containment, status: status)
                    incidents.append(incident)
                }
                completion(incidents)
            } catch {
                print("InciWeb parse error: \(error.localizedDescription)")
                completion([])
            }
        }
        task.resume()
    }
}



