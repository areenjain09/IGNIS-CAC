
// Auto-generated Real-Time CAL FIRE Incidents Data
// Generated on: 2025-08-02 17:45:23
// Source: CAL FIRE Incidents API

import Foundation
import CoreLocation
// import MapKit // temporarily disabled

struct CALFireIncident: Identifiable, Codable {
    let id = UUID()
    let name: String
    let acresBurned: Double
    let percentContained: Double
    let isActive: Bool
    let startedDate: String
    let extinguishedDate: String
    let county: String
    let location: String
    let adminUnit: String
    let type: String
    let url: String
    let latitude: Double
    let longitude: Double
    let properties: [String: String]
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var intensity: FireIntensity {
        if acresBurned > 10000 {
            return .extreme
        } else if acresBurned > 1000 {
            return .high
        } else if acresBurned > 100 {
            return .medium
        } else {
            return .low
        }
    }
    
    var statusColor: String {
        if isActive {
            return "wsRed"
        } else {
            return "wsOrange"
        }
    }
    
    var statusText: String {
        if isActive {
            return "ACTIVE"
        } else {
            return "CONTAINED"
        }
    }
}

// Real-Time CAL FIRE Incidents Data
let calFireIncidents: [CALFireIncident] = [

    CALFireIncident(
        name: "Green Fire",
        acresBurned: 19022.0,
        percentContained: 96.0,
        isActive: true,
        startedDate: "2025-07-01",
        extinguishedDate: "",
        county: "Shasta",
        location: "North of the Pit River, Shasta",
        adminUnit: "United States Forest Service: Shasta Trinity National Forest",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/1/green-fire/",
        latitude: 40.834939,
        longitude: -122.094146,
        properties: {'Name': 'Green Fire', 'Final': False, 'Updated': '2025-08-02T11:50:52Z', 'Started': '2025-07-01T21:37:01Z', 'AdminUnit': 'United States Forest Service: Shasta Trinity National Forest', 'AdminUnitUrl': None, 'County': 'Shasta', 'Location': 'North of the Pit River, Shasta', 'AcresBurned': 19022.0, 'PercentContained': 96.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -122.094146, 'Latitude': 40.834939, 'Type': 'Wildfire', 'UniqueId': '4e07582c-e388-47e6-8408-cdc7142e7091', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/1/green-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-01', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Marble Complex Fire",
        acresBurned: 747.0,
        percentContained: 90.0,
        isActive: true,
        startedDate: "2025-07-03",
        extinguishedDate: "",
        county: "Siskiyou",
        location: "Marble Mountain Wilderness",
        adminUnit: "United States Forest Service: Klamath National Forest",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/3/marble-complex-fire/",
        latitude: 41.52404,
        longitude: -123.13222,
        properties: {'Name': 'Marble Complex Fire', 'Final': False, 'Updated': '2025-07-29T10:16:36Z', 'Started': '2025-07-03T11:20:53Z', 'AdminUnit': 'United States Forest Service: Klamath National Forest', 'AdminUnitUrl': None, 'County': 'Siskiyou', 'Location': 'Marble Mountain Wilderness', 'AcresBurned': 747.0, 'PercentContained': 90.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -123.13222, 'Latitude': 41.52404, 'Type': 'Wildfire', 'UniqueId': '639d1196-4ded-42d0-a787-06d84bd8082f', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/3/marble-complex-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-03', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Orleans Complex ",
        acresBurned: 21489.0,
        percentContained: 80.0,
        isActive: true,
        startedDate: "2025-07-09",
        extinguishedDate: "",
        county: "Del Norte, Siskiyou",
        location: "10 miles East of Orleans ",
        adminUnit: "United States Forest Service: Six Rivers National Forest ",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/9/orleans-complex/",
        latitude: 41.32555556,
        longitude: -123.41777778,
        properties: {'Name': 'Orleans Complex ', 'Final': False, 'Updated': '2025-08-02T10:03:06Z', 'Started': '2025-07-09T17:39:03Z', 'AdminUnit': 'United States Forest Service: Six Rivers National Forest ', 'AdminUnitUrl': None, 'County': 'Del Norte, Siskiyou', 'Location': '10 miles East of Orleans ', 'AcresBurned': 21489.0, 'PercentContained': 80.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -123.41777778, 'Latitude': 41.32555556, 'Type': 'Wildfire', 'UniqueId': 'c1c21095-0f44-4ddb-8b34-6b9c06507f3b', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/9/orleans-complex/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-09', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Medicine Fire",
        acresBurned: 263.0,
        percentContained: 85.0,
        isActive: true,
        startedDate: "2025-07-27",
        extinguishedDate: "",
        county: "Mendocino",
        location: "Rifle Range Road north of Refuse Road, Covelo, Mendocino County, CA.  ",
        adminUnit: "CAL FIRE Mendocino Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/27/medicine-fire/",
        latitude: 39.831628,
        longitude: -123.267618,
        properties: {'Name': 'Medicine Fire', 'Final': False, 'Updated': '2025-08-02T09:59:35Z', 'Started': '2025-07-27T15:25:05Z', 'AdminUnit': 'CAL FIRE Mendocino Unit', 'AdminUnitUrl': None, 'County': 'Mendocino', 'Location': 'Rifle Range Road north of Refuse Road, Covelo, Mendocino County, CA.  ', 'AcresBurned': 263.0, 'PercentContained': 85.0, 'ControlStatement': None, 'AgencyNames': "Mendocino County Sheriff's Office, Covelo Fire Protection, US Forest Service, California Conservation Corps, California Department of Corrections and Rehabilitation", 'Longitude': -123.267618, 'Latitude': 39.831628, 'Type': 'Wildfire', 'UniqueId': 'f65d7124-a461-4c82-b892-d55105860d13', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/27/medicine-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-27', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Lassen Fire",
        acresBurned: 51.0,
        percentContained: 85.0,
        isActive: true,
        startedDate: "2025-08-01",
        extinguishedDate: "",
        county: "Tehama",
        location: "Tehama Vina Road & Champlin Slough, Los Molinos",
        adminUnit: "CAL FIRE Tehama-Glenn Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/1/lassen-fire/",
        latitude: 40.028565,
        longitude: -122.086035,
        properties: {'Name': 'Lassen Fire', 'Final': False, 'Updated': '2025-08-02T09:59:40Z', 'Started': '2025-08-01T13:14:15Z', 'AdminUnit': 'CAL FIRE Tehama-Glenn Unit', 'AdminUnitUrl': None, 'County': 'Tehama', 'Location': 'Tehama Vina Road & Champlin Slough, Los Molinos', 'AcresBurned': 51.0, 'PercentContained': 85.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -122.086035, 'Latitude': 40.028565, 'Type': 'Wildfire', 'UniqueId': 'c7c33e08-b93d-4de0-8394-6ef53d2ce621', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/1/lassen-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-01', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Howards Fire",
        acresBurned: 100.0,
        percentContained: 45.0,
        isActive: true,
        startedDate: "2025-07-31",
        extinguishedDate: "",
        county: "Modoc",
        location: "Highway 139 and Loveness Road, Ambrose",
        adminUnit: "Modoc National Forest",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/31/howards-fire/",
        latitude: 41.48008,
        longitude: -120.957447,
        properties: {'Name': 'Howards Fire', 'Final': False, 'Updated': '2025-08-01T06:47:03-07:00', 'Started': '2025-07-31T14:09:50Z', 'AdminUnit': 'Modoc National Forest', 'AdminUnitUrl': None, 'County': 'Modoc', 'Location': 'Highway 139 and Loveness Road, Ambrose', 'AcresBurned': 100.0, 'PercentContained': 45.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.957447, 'Latitude': 41.48008, 'Type': 'Wildfire', 'UniqueId': '77bd9c52-9888-406b-8e75-f416723bbf98', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/31/howards-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-31', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "1-4 Fire",
        acresBurned: 259.6,
        percentContained: 25.0,
        isActive: true,
        startedDate: "2025-07-31",
        extinguishedDate: "",
        county: "Lassen",
        location: "Paiute Lane and Peak Road, Susanville",
        adminUnit: "CAL FIRE Lassen-Modoc Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/7/31/1-4-fire/",
        latitude: 40.445172,
        longitude: -120.656672,
        properties: {'Name': '1-4 Fire', 'Final': False, 'Updated': '2025-08-01T10:27:30-07:00', 'Started': '2025-07-31T16:15:25Z', 'AdminUnit': 'CAL FIRE Lassen-Modoc Unit', 'AdminUnitUrl': None, 'County': 'Lassen', 'Location': 'Paiute Lane and Peak Road, Susanville', 'AcresBurned': 259.6, 'PercentContained': 25.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.656672, 'Latitude': 40.445172, 'Type': 'Wildfire', 'UniqueId': '7f9b2183-819f-4487-926b-aa36b4a31c1b', 'Url': 'https://www.fire.ca.gov/incidents/2025/7/31/1-4-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-07-31', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "4-8 Fire",
        acresBurned: 25.0,
        percentContained: None,
        isActive: true,
        startedDate: "2025-08-01",
        extinguishedDate: "",
        county: "Modoc",
        location: "Kearny Road & Carson Road, California Pines",
        adminUnit: "CAL FIRE Lassen-Modoc Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/1/4-8-fire/",
        latitude: 41.319441,
        longitude: -120.747715,
        properties: {'Name': '4-8 Fire', 'Final': False, 'Updated': '2025-08-01T15:40:22Z', 'Started': '2025-08-01T15:03:42Z', 'AdminUnit': 'CAL FIRE Lassen-Modoc Unit', 'AdminUnitUrl': None, 'County': 'Modoc', 'Location': 'Kearny Road & Carson Road, California Pines', 'AcresBurned': 25.0, 'PercentContained': None, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.747715, 'Latitude': 41.319441, 'Type': 'Wildfire', 'UniqueId': '33d6cf9b-2d77-4039-baac-19b90988f804', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/1/4-8-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-01', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Gifford Fire ",
        acresBurned: 30519.0,
        percentContained: 5.0,
        isActive: true,
        startedDate: "2025-08-01",
        extinguishedDate: "",
        county: "San Luis Obispo, Santa Barbara",
        location: "Highway 166 Northeast of Santa Maria",
        adminUnit: "Unified Command- Los Padres National Forest & Santa Barbara County Fire",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/1/gifford-fire/",
        latitude: 35.102947,
        longitude: -120.116814,
        properties: {'Name': 'Gifford Fire ', 'Final': False, 'Updated': '2025-08-02T17:07:35Z', 'Started': '2025-08-01T15:44:29Z', 'AdminUnit': 'Unified Command- Los Padres National Forest & Santa Barbara County Fire', 'AdminUnitUrl': None, 'County': 'San Luis Obispo, Santa Barbara', 'Location': 'Highway 166 Northeast of Santa Maria', 'AcresBurned': 30519.0, 'PercentContained': 5.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.116814, 'Latitude': 35.102947, 'Type': 'Wildfire', 'UniqueId': 'fb7c1cc7-8104-4776-b89e-fd27cb9b7be9', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/1/gifford-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-01', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Donovan Fire",
        acresBurned: 30.0,
        percentContained: None,
        isActive: true,
        startedDate: "2025-08-02",
        extinguishedDate: "",
        county: "San Luis Obispo",
        location: "La Panza Road & Little Farm Road, Creston",
        adminUnit: "CAL FIRE San Luis Obispo Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/2/donovan-fire/",
        latitude: 35.527328,
        longitude: -120.508946,
        properties: {'Name': 'Donovan Fire', 'Final': False, 'Updated': '2025-08-02T16:48:07Z', 'Started': '2025-08-02T13:58:03Z', 'AdminUnit': 'CAL FIRE San Luis Obispo Unit', 'AdminUnitUrl': None, 'County': 'San Luis Obispo', 'Location': 'La Panza Road & Little Farm Road, Creston', 'AcresBurned': 30.0, 'PercentContained': None, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.508946, 'Latitude': 35.527328, 'Type': 'Wildfire', 'UniqueId': 'ea201a75-e79c-4ff4-91fb-3ccc9142f1aa', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/2/donovan-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-02', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Fremont Fire",
        acresBurned: 26.3,
        percentContained: None,
        isActive: true,
        startedDate: "2025-08-02",
        extinguishedDate: "",
        county: "San Bernardino",
        location: "Near Fremontia Road and Mesquite Road ",
        adminUnit: "CAL FIRE San Bernardino Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/2/fremont-fire/",
        latitude: 34.429401,
        longitude: -117.653566,
        properties: {'Name': 'Fremont Fire', 'Final': False, 'Updated': '2025-08-02T15:32:49Z', 'Started': '2025-08-02T13:44:52Z', 'AdminUnit': 'CAL FIRE San Bernardino Unit', 'AdminUnitUrl': None, 'County': 'San Bernardino', 'Location': 'Near Fremontia Road and Mesquite Road ', 'AcresBurned': 26.3, 'PercentContained': None, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.653566, 'Latitude': 34.429401, 'Type': 'Wildfire', 'UniqueId': '86ecd8ea-4e67-400a-970f-c0d7033232ca', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/2/fremont-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-02', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Radar Fire ",
        acresBurned: 15.0,
        percentContained: None,
        isActive: true,
        startedDate: "2025-08-02",
        extinguishedDate: "",
        county: "Modoc",
        location: "Southwest of Lone Pine Lake",
        adminUnit: "Modoc National Forest",
        type: "Fire",
        url: "https://www.fire.ca.gov/incidents/2025/8/2/radar-fire/",
        latitude: 41.7203467,
        longitude: -121.1305479,
        properties: {'Name': 'Radar Fire ', 'Final': False, 'Updated': '2025-08-02T16:57:12Z', 'Started': '2025-08-02T16:53:17Z', 'AdminUnit': 'Modoc National Forest', 'AdminUnitUrl': None, 'County': 'Modoc', 'Location': 'Southwest of Lone Pine Lake', 'AcresBurned': 15.0, 'PercentContained': None, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -121.1305479, 'Latitude': 41.7203467, 'Type': 'Fire', 'UniqueId': '21cd718c-9ec8-4f5b-a65b-bcf3d1c03450', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/2/radar-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-02', 'IsActive': True, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Oak Fire",
        acresBurned: 10.0,
        percentContained: None,
        isActive: true,
        startedDate: "2025-08-02",
        extinguishedDate: "",
        county: "Riverside",
        location: "Unknown / TBD",
        adminUnit: "CAL FIRE Riverside Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/8/2/oak-fire/",
        latitude: 34.003628,
        longitude: -117.162599,
        properties: {'Name': 'Oak Fire', 'Final': False, 'Updated': '2025-08-02T17:21:37-07:00', 'Started': '2025-08-02T17:00:34Z', 'AdminUnit': 'CAL FIRE Riverside Unit', 'AdminUnitUrl': None, 'County': 'Riverside', 'Location': 'Unknown / TBD', 'AcresBurned': 10.0, 'PercentContained': None, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.162599, 'Latitude': 34.003628, 'Type': 'Wildfire', 'UniqueId': 'f8074843-7b89-41ff-b0bb-8d9fb609a236', 'Url': 'https://www.fire.ca.gov/incidents/2025/8/2/oak-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-08-02', 'IsActive': True, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Oak Fire",
        acresBurned: 42.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-01",
        extinguishedDate: "",
        county: "Santa Barbara",
        location: "Tepesquet Canyon/Santa Maria Mesa Road, Santa Maria",
        adminUnit: "Santa Barbara County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/1/oak-fire/",
        latitude: 34.883723,
        longitude: -120.246601,
        properties: {'Name': 'Oak Fire', 'Final': True, 'Updated': '2025-01-12T09:36:42Z', 'Started': '2025-01-01T20:08:00Z', 'AdminUnit': 'Santa Barbara County Fire Department', 'AdminUnitUrl': None, 'County': 'Santa Barbara', 'Location': 'Tepesquet Canyon/Santa Maria Mesa Road, Santa Maria', 'AcresBurned': 42.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -120.246601, 'Latitude': 34.883723, 'Type': 'Wildfire', 'UniqueId': 'e2f7d285-7b47-40c0-802e-b7de9e51da56', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/1/oak-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-01', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Border Fire",
        acresBurned: 25.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-01",
        extinguishedDate: "",
        county: "San Diego",
        location: "Otay Mountain Wilderness",
        adminUnit: "BLM/El Centro Office",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/1/border-fire/",
        latitude: 32.59853,
        longitude: -116.82817,
        properties: {'Name': 'Border Fire', 'Final': True, 'Updated': '2025-01-02T22:04:25Z', 'Started': '2025-01-01T18:23:09Z', 'AdminUnit': 'BLM/El Centro Office', 'AdminUnitUrl': None, 'County': 'San Diego', 'Location': 'Otay Mountain Wilderness', 'AcresBurned': 25.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -116.82817, 'Latitude': 32.59853, 'Type': 'Wildfire', 'UniqueId': '4eef0191-65aa-46a0-8227-d1553896a5b0', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/1/border-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-01', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Palisades Fire",
        acresBurned: 23448.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-07",
        extinguishedDate: "2025-01-31",
        county: "Los Angeles",
        location: "Southeast of Palisades Drive, Pacific Palisades",
        adminUnit: "Los Angeles City Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/7/palisades-fire/",
        latitude: 34.07022,
        longitude: -118.54453,
        properties: {'Name': 'Palisades Fire', 'Final': True, 'Updated': '2025-05-20T11:56:12Z', 'Started': '2025-01-07T10:30:00Z', 'AdminUnit': 'Los Angeles City Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': 'Southeast of Palisades Drive, Pacific Palisades', 'AcresBurned': 23448.0, 'PercentContained': 100.0, 'ControlStatement': '', 'AgencyNames': 'City of Los Angeles, Los Angeles Department of Water & Power, Los Angeles Department of Transportation, Los Angeles City Emergency Management Department, Los Angeles County Office of Emergency Managment, Los Angeles County Department of Animal Control, Los Angeles Community Brigade, Los Angeles County Department of Public Works, Los Angeles County Department of Public Health, City of Malibu, California State Parks, Los Virgenes Municipal Water District, Southern California Edison, Pepperdine University, California Highway Patrol, American Red Cross, National Park Service, Gabrieleno Band of Mission Indians-Kizh-Nation.', 'Longitude': -118.54453, 'Latitude': 34.07022, 'Type': 'Wildfire', 'UniqueId': 'abfed7a3-794a-4294-9852-43176dcbc18a', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/7/palisades-fire/', 'ExtinguishedDate': '2025-01-31T10:48:30Z', 'ExtinguishedDateOnly': '2025-01-31', 'StartedDateOnly': '2025-01-07', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Eaton Fire",
        acresBurned: 14021.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-07",
        extinguishedDate: "2025-01-31",
        county: "Los Angeles",
        location: "Near Altadena Drive and Midwick Drive, Altadena/Pasadena",
        adminUnit: "Los Angeles County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/7/eaton-fire/",
        latitude: 34.203483,
        longitude: -118.069155,
        properties: {'Name': 'Eaton Fire', 'Final': True, 'Updated': '2025-05-20T11:57:02Z', 'Started': '2025-01-07T18:18:00Z', 'AdminUnit': 'Los Angeles County Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': 'Near Altadena Drive and Midwick Drive, Altadena/Pasadena', 'AcresBurned': 14021.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': ', LA County Mental Health, LA County Dept. Public Works, Pasadena Water and Power, LA County Medical Examiner, LA County Public Health, Southern California Edison, Sierra Madre Fire Department, Gabrieleno Band of Mission Indians - Kizh Nation, Arcadia Fire Department, Southern California Gas, California National Guard', 'Longitude': -118.069155, 'Latitude': 34.203483, 'Type': 'Wildfire', 'UniqueId': 'dbfa574e-1b10-4467-b5e5-7d1c06ebc8dc', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/7/eaton-fire/', 'ExtinguishedDate': '2025-01-31T10:48:42Z', 'ExtinguishedDateOnly': '2025-01-31', 'StartedDateOnly': '2025-01-07', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Hurst Fire",
        acresBurned: 799.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-07",
        extinguishedDate: "2025-01-16",
        county: "Los Angeles",
        location: "Near Diamond Road, Sylmar",
        adminUnit: "Los Angeles City Fire Department, United States Forest Service, Los Angeles Fire Department, Los Angles County Sheriff",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/7/hurst-fire/",
        latitude: 34.32533,
        longitude: -118.478134,
        properties: {'Name': 'Hurst Fire', 'Final': True, 'Updated': '2025-01-16T21:51:53Z', 'Started': '2025-01-07T22:29:30Z', 'AdminUnit': 'Los Angeles City Fire Department, United States Forest Service, Los Angeles Fire Department, Los Angles County Sheriff', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': 'Near Diamond Road, Sylmar', 'AcresBurned': 799.0, 'PercentContained': 100.0, 'ControlStatement': '', 'AgencyNames': '', 'Longitude': -118.478134, 'Latitude': 34.32533, 'Type': 'Wildfire', 'UniqueId': 'ed36cf94-75d8-43f6-913a-d15646907311', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/7/hurst-fire/', 'ExtinguishedDate': '2025-01-16T00:00:00Z', 'ExtinguishedDateOnly': '2025-01-16', 'StartedDateOnly': '2025-01-07', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Tyler Fire",
        acresBurned: 11.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-08",
        extinguishedDate: "",
        county: "Riverside",
        location: "Tyler Street & 47th Avenue, Coachella",
        adminUnit: "CAL FIRE Riverside Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/8/tyler-fire/",
        latitude: 33.706565,
        longitude: -116.164126,
        properties: {'Name': 'Tyler Fire', 'Final': True, 'Updated': '2025-01-10T11:18:58Z', 'Started': '2025-01-08T03:25:39Z', 'AdminUnit': 'CAL FIRE Riverside Unit', 'AdminUnitUrl': None, 'County': 'Riverside', 'Location': 'Tyler Street & 47th Avenue, Coachella', 'AcresBurned': 11.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -116.164126, 'Latitude': 33.706565, 'Type': 'Wildfire', 'UniqueId': 'c3e0b57e-f5b9-41e0-b9ec-eb524797c874', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/8/tyler-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-08', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Woodley Fire",
        acresBurned: 30.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-08",
        extinguishedDate: "",
        county: "Los Angeles",
        location: "North Woodley Avenue, Sepulveda Basin",
        adminUnit: "Los Angeles City Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/8/woodley-fire/",
        latitude: 34.17973,
        longitude: -118.47438,
        properties: {'Name': 'Woodley Fire', 'Final': True, 'Updated': '2025-01-08T20:35:53Z', 'Started': '2025-01-08T06:15:27Z', 'AdminUnit': 'Los Angeles City Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': 'North Woodley Avenue, Sepulveda Basin', 'AcresBurned': 30.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -118.47438, 'Latitude': 34.17973, 'Type': 'Wildfire', 'UniqueId': 'c2159108-ab33-4b74-8ef1-3706df7aecda', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/8/woodley-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-08', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Olivas Fire",
        acresBurned: 11.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-08",
        extinguishedDate: "",
        county: "Ventura",
        location: "Olivas Park Dr & E Harbor Blvd, Ventura",
        adminUnit: "Ventura County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/8/olivas-fire/",
        latitude: 34.244456,
        longitude: -119.2567768,
        properties: {'Name': 'Olivas Fire', 'Final': True, 'Updated': '2025-01-13T14:12:44Z', 'Started': '2025-01-08T10:44:16Z', 'AdminUnit': 'Ventura County Fire Department', 'AdminUnitUrl': None, 'County': 'Ventura', 'Location': 'Olivas Park Dr & E Harbor Blvd, Ventura', 'AcresBurned': 11.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -119.2567768, 'Latitude': 34.244456, 'Type': 'Wildfire', 'UniqueId': '8ea1537d-2560-4d08-bfe0-060cf5275e54', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/8/olivas-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-08', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Lidia Fire",
        acresBurned: 395.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-08",
        extinguishedDate: "2025-01-11",
        county: "Los Angeles",
        location: "5700 Block of Soledad Canyon Road, Acton",
        adminUnit: "Unified Command: Angeles National Forest and Los Angeles County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/8/lidia-fire/",
        latitude: 34.4408,
        longitude: -118.2433,
        properties: {'Name': 'Lidia Fire', 'Final': True, 'Updated': '2025-01-11T07:41:52Z', 'Started': '2025-01-08T14:07:38Z', 'AdminUnit': 'Unified Command: Angeles National Forest and Los Angeles County Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': '5700 Block of Soledad Canyon Road, Acton', 'AcresBurned': 395.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -118.2433, 'Latitude': 34.4408, 'Type': 'Wildfire', 'UniqueId': '83adc92b-bd6c-458a-a2b1-43b3ee2c27b3', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/8/lidia-fire/', 'ExtinguishedDate': '2025-01-11T07:40:17Z', 'ExtinguishedDateOnly': '2025-01-11', 'StartedDateOnly': '2025-01-08', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Sunset Fire ",
        acresBurned: 42.8,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-08",
        extinguishedDate: "",
        county: "Los Angeles",
        location: "2300 block Solar Dr, Hollywood Hills",
        adminUnit: "Los Angeles Fire Department ",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/8/sunset-fire/",
        latitude: 34.1105,
        longitude: -118.3536,
        properties: {'Name': 'Sunset Fire ', 'Final': True, 'Updated': '2025-01-09T15:58:10Z', 'Started': '2025-01-08T17:57:36Z', 'AdminUnit': 'Los Angeles Fire Department ', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': '2300 block Solar Dr, Hollywood Hills', 'AcresBurned': 42.8, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -118.3536, 'Latitude': 34.1105, 'Type': 'Wildfire', 'UniqueId': '3b0d8af8-f3c9-4629-8735-641d9f6af3e7', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/8/sunset-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-08', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Kenneth Fire",
        acresBurned: 1052.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-09",
        extinguishedDate: "2025-01-12",
        county: "Los Angeles, Ventura",
        location: "Victory Boulevard west of Gilmore Street, West Hills",
        adminUnit: "Unified Command: Los Angeles City Fire Department and Ventura County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/9/kenneth-fire/",
        latitude: 34.185198,
        longitude: -118.66991,
        properties: {'Name': 'Kenneth Fire', 'Final': True, 'Updated': '2025-01-12T07:48:29Z', 'Started': '2025-01-09T15:34:13Z', 'AdminUnit': 'Unified Command: Los Angeles City Fire Department and Ventura County Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles, Ventura', 'Location': 'Victory Boulevard west of Gilmore Street, West Hills', 'AcresBurned': 1052.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -118.66991, 'Latitude': 34.185198, 'Type': 'Wildfire', 'UniqueId': '98dad47e-805e-4300-8220-c908df687b4b', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/9/kenneth-fire/', 'ExtinguishedDate': '2025-01-12T07:48:12Z', 'ExtinguishedDateOnly': '2025-01-12', 'StartedDateOnly': '2025-01-09', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Archer Fire",
        acresBurned: 19.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-10",
        extinguishedDate: "2025-01-10",
        county: "Los Angeles",
        location: "Sesnon Boulevard, North of Meadowlark Avenue, Granada Hills",
        adminUnit: "Los Angeles City Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/10/archer-fire/",
        latitude: 34.3087,
        longitude: -118.5111,
        properties: {'Name': 'Archer Fire', 'Final': True, 'Updated': '2025-01-11T08:41:30Z', 'Started': '2025-01-10T11:24:44Z', 'AdminUnit': 'Los Angeles City Fire Department', 'AdminUnitUrl': None, 'County': 'Los Angeles', 'Location': 'Sesnon Boulevard, North of Meadowlark Avenue, Granada Hills', 'AcresBurned': 19.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -118.5111, 'Latitude': 34.3087, 'Type': 'Wildfire', 'UniqueId': 'a93eab36-e8a3-4a4e-be4d-2372e3ba4957', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/10/archer-fire/', 'ExtinguishedDate': '2025-01-10T08:41:10Z', 'ExtinguishedDateOnly': '2025-01-10', 'StartedDateOnly': '2025-01-10', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Auto Fire",
        acresBurned: 61.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-13",
        extinguishedDate: "",
        county: "Ventura",
        location: "Near Auto Center Drive, Ventura",
        adminUnit: "Ventura County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/13/auto-fire/",
        latitude: 34.23661,
        longitude: -119.20224,
        properties: {'Name': 'Auto Fire', 'Final': True, 'Updated': '2025-01-18T00:09:04Z', 'Started': '2025-01-13T21:25:00Z', 'AdminUnit': 'Ventura County Fire Department', 'AdminUnitUrl': None, 'County': 'Ventura', 'Location': 'Near Auto Center Drive, Ventura', 'AcresBurned': 61.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -119.20224, 'Latitude': 34.23661, 'Type': 'Wildfire', 'UniqueId': '11055429-59f4-49dc-b759-a0c0d1225efc', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/13/auto-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-13', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Scout Fire",
        acresBurned: 2.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-14",
        extinguishedDate: "2025-01-14",
        county: "Riverside",
        location: "Between Indian Hill Road and the Santa Ana River, Riverside  ",
        adminUnit: "CAL FIRE Riverside Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/14/scout-fire/",
        latitude: 33.989,
        longitude: -117.3887,
        properties: {'Name': 'Scout Fire', 'Final': True, 'Updated': '2025-01-16T21:56:11Z', 'Started': '2025-01-14T13:10:51Z', 'AdminUnit': 'CAL FIRE Riverside Unit', 'AdminUnitUrl': None, 'County': 'Riverside', 'Location': 'Between Indian Hill Road and the Santa Ana River, Riverside  ', 'AcresBurned': 2.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.3887, 'Latitude': 33.989, 'Type': 'Wildfire', 'UniqueId': '8a3dcaf5-4724-4176-83d4-08f96c79ffb6', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/14/scout-fire/', 'ExtinguishedDate': '2025-01-14T00:00:00Z', 'ExtinguishedDateOnly': '2025-01-14', 'StartedDateOnly': '2025-01-14', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Little Mountain Fire",
        acresBurned: 34.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-15",
        extinguishedDate: "2025-01-16",
        county: "San Bernardino",
        location: "Near Little Mountain Drive, San Bernardino",
        adminUnit: "San Bernardino County Fire Department",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/15/little-mountain-fire/",
        latitude: 34.154384,
        longitude: -117.32064,
        properties: {'Name': 'Little Mountain Fire', 'Final': True, 'Updated': '2025-01-16T21:48:01Z', 'Started': '2025-01-15T14:44:41Z', 'AdminUnit': 'San Bernardino County Fire Department', 'AdminUnitUrl': None, 'County': 'San Bernardino', 'Location': 'Near Little Mountain Drive, San Bernardino', 'AcresBurned': 34.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.32064, 'Latitude': 34.154384, 'Type': 'Wildfire', 'UniqueId': '6c143c7e-d33c-4d0b-b434-d33a13705328', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/15/little-mountain-fire/', 'ExtinguishedDate': '2025-01-16T00:00:00Z', 'ExtinguishedDateOnly': '2025-01-16', 'StartedDateOnly': '2025-01-15', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Lilac Fire",
        acresBurned: 85.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-21",
        extinguishedDate: "2025-01-22",
        county: "San Diego",
        location: "Old Hwy 395 and Lilac Road, Bonsall",
        adminUnit: "CAL FIRE San Diego Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/21/lilac-fire/",
        latitude: 33.30932,
        longitude: -117.152114,
        properties: {'Name': 'Lilac Fire', 'Final': True, 'Updated': '2025-01-23T00:57:42Z', 'Started': '2025-01-21T01:19:23Z', 'AdminUnit': 'CAL FIRE San Diego Unit', 'AdminUnitUrl': None, 'County': 'San Diego', 'Location': 'Old Hwy 395 and Lilac Road, Bonsall', 'AcresBurned': 85.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.152114, 'Latitude': 33.30932, 'Type': 'Wildfire', 'UniqueId': 'db6f387b-2654-44a6-815e-20491c5a37a2', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/21/lilac-fire/', 'ExtinguishedDate': '2025-01-22T00:00:00Z', 'ExtinguishedDateOnly': '2025-01-22', 'StartedDateOnly': '2025-01-21', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Pala Fire",
        acresBurned: 16.8,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-21",
        extinguishedDate: "",
        county: "San Diego",
        location: "Old Hwy 395 and Canonita Dr, Fallbrook",
        adminUnit: "CAL FIRE San Diego Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/21/pala-fire/",
        latitude: 33.363226,
        longitude: -117.162897,
        properties: {'Name': 'Pala Fire', 'Final': True, 'Updated': '2025-01-21T21:49:51Z', 'Started': '2025-01-21T02:16:24Z', 'AdminUnit': 'CAL FIRE San Diego Unit', 'AdminUnitUrl': None, 'County': 'San Diego', 'Location': 'Old Hwy 395 and Canonita Dr, Fallbrook', 'AcresBurned': 16.8, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.162897, 'Latitude': 33.363226, 'Type': 'Wildfire', 'UniqueId': '74af6e1b-0ca9-4094-869d-ecae0a778cfb', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/21/pala-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-21', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Friars Fire",
        acresBurned: 3.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-21",
        extinguishedDate: "",
        county: "San Diego",
        location: "Friars Road and Via De La Moda, San Diego",
        adminUnit: "City of San Diego Fire-Rescue",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/21/friars-fire/",
        latitude: 32.7702,
        longitude: -117.1698,
        properties: {'Name': 'Friars Fire', 'Final': True, 'Updated': '2025-01-21T21:48:28Z', 'Started': '2025-01-21T12:32:09Z', 'AdminUnit': 'City of San Diego Fire-Rescue', 'AdminUnitUrl': None, 'County': 'San Diego', 'Location': 'Friars Road and Via De La Moda, San Diego', 'AcresBurned': 3.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.1698, 'Latitude': 32.7702, 'Type': 'Wildfire', 'UniqueId': '6bb588ff-4f53-492f-9e3a-1ff5900f6345', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/21/friars-fire/', 'ExtinguishedDate': '', 'ExtinguishedDateOnly': '', 'StartedDateOnly': '2025-01-21', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Ncfr3 4 Fire",
        acresBurned: 80.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-21",
        extinguishedDate: "2025-01-21",
        county: "San Diego",
        location: "West Lilac Road, Near Bonsall",
        adminUnit: "None",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/21/ncfr3-4-fire/",
        latitude: 33.299921,
        longitude: -117.174205,
        properties: {'Name': 'Ncfr3 4 Fire', 'Final': True, 'Updated': '2025-06-16T08:31:43Z', 'Started': '2025-01-21T10:19:46Z', 'AdminUnit': None, 'AdminUnitUrl': None, 'County': 'San Diego', 'Location': 'West Lilac Road, Near Bonsall', 'AcresBurned': 80.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': '', 'Longitude': -117.174205, 'Latitude': 33.299921, 'Type': 'Wildfire', 'UniqueId': '8dcc0ed8-641f-4b85-b853-9ed4473f5e51', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/21/ncfr3-4-fire/', 'ExtinguishedDate': '2025-01-21T08:14:23Z', 'ExtinguishedDateOnly': '2025-01-21', 'StartedDateOnly': '2025-01-21', 'IsActive': False, 'CalFireIncident': False, 'NotificationDesired': False}
    ),
    CALFireIncident(
        name: "Clay Fire",
        acresBurned: 39.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-01-21",
        extinguishedDate: "2025-01-25",
        county: "Riverside",
        location: "Santa Ana River Bottom near Pedley Road and Van Buren Boulevard, Jurupa Valley",
        adminUnit: "CAL FIRE Riverside Unit",
        type: "Wildfire",
        url: "https://www.fire.ca.gov/incidents/2025/1/21/clay-fire/",
        latitude: 33.96682,
        longitude: -117.47055,
        properties: {'Name': 'Clay Fire', 'Final': True, 'Updated': '2025-01-25T06:54:36Z', 'Started': '2025-01-21T17:00:13Z', 'AdminUnit': 'CAL FIRE Riverside Unit', 'AdminUnitUrl': None, 'County': 'Riverside', 'Location': 'Santa Ana River Bottom near Pedley Road and Van Buren Boulevard, Jurupa Valley', 'AcresBurned': 39.0, 'PercentContained': 100.0, 'ControlStatement': None, 'AgencyNames': 'Riverside City Fire, City of Jurupa Valley, City of Eastvale', 'Longitude': -117.47055, 'Latitude': 33.96682, 'Type': 'Wildfire', 'UniqueId': 'b8b66c83-2a4d-495e-b51c-6dc071ddaa5a', 'Url': 'https://www.fire.ca.gov/incidents/2025/1/21/clay-fire/', 'ExtinguishedDate': '2025-01-25T00:00:00Z', 'ExtinguishedDateOnly': '2025-01-25', 'StartedDateOnly': '2025-01-21', 'IsActive': False, 'CalFireIncident': True, 'NotificationDesired': False}
    ),
]

// Extension to integrate with existing map
extension CALFireIncident {
    func toFireLocation() -> FireLocation {
        return FireLocation(
            name: name,
            latitude: latitude,
            longitude: longitude,
            intensity: intensity.rawValue,
            containment: percentContained,
            acres: acresBurned,
            started: startedDate,
            counties: county,
            cause: "Unknown",
            evacuationInfo: "Check local authorities",
            structuresAffected: "Unknown"
        )
    }
}
