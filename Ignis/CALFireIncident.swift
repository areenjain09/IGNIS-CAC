//
//  CALFireIncident.swift
//  Ignis
//
//  Created by Areen Jain on 8/4/25.
//


import SwiftUI
import CoreLocation
// import MapKit // temporarily disabled
// Real-Time CAL FIRE Incidents Data - Optimized
struct CALFireIncident: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let acresBurned: Double
    let percentContained: Double
    let isActive: Bool
    let startedDate: String
    let county: String
    let location: String
    let latitude: Double
    let longitude: Double
    let url: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var intensityLevel: Int {
        if acresBurned > 10000 { return 3 }
        else if acresBurned > 1000 { return 2 }
        else if acresBurned > 100 { return 1 }
        else { return 0 }
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
    
    // Hashable conformance for better performance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CALFireIncident, rhs: CALFireIncident) -> Bool {
        return lhs.id == rhs.id
    }
}
// Real-Time CAL FIRE Data - Generated on 2025-08-02 18:56:49
// Active Fires: 13, Recent Contained: 28
let calFireIncidents: [CALFireIncident] = [
    CALFireIncident(
        name: "Green Fire",
        acresBurned: 19022.0,
        percentContained: 96.0,
        isActive: true,
        startedDate: "2025-07-01",
        county: "Shasta",
        location: "North of the Pit River, Shasta",
        latitude: 40.834939,
        longitude: -122.094146,
        url: "https://www.fire.ca.gov/incidents/2025/7/1/green-fire/"
    ),
    CALFireIncident(
        name: "Marble Complex Fire",
        acresBurned: 747.0,
        percentContained: 90.0,
        isActive: true,
        startedDate: "2025-07-03",
        county: "Siskiyou",
        location: "Marble Mountain Wilderness",
        latitude: 41.52404,
        longitude: -123.13222,
        url: "https://www.fire.ca.gov/incidents/2025/7/3/marble-complex-fire/"
    ),
    CALFireIncident(
        name: "Orleans Complex ",
        acresBurned: 21489.0,
        percentContained: 80.0,
        isActive: true,
        startedDate: "2025-07-09",
        county: "Del Norte, Siskiyou",
        location: "10 miles East of Orleans ",
        latitude: 41.32555556,
        longitude: -123.41777778,
        url: "https://www.fire.ca.gov/incidents/2025/7/9/orleans-complex/"
    ),
    CALFireIncident(
        name: "Medicine Fire",
        acresBurned: 263.0,
        percentContained: 85.0,
        isActive: true,
        startedDate: "2025-07-27",
        county: "Mendocino",
        location: "Rifle Range Road north of Refuse Road, Covelo, Mendocino County, CA.  ",
        latitude: 39.831628,
        longitude: -123.267618,
        url: "https://www.fire.ca.gov/incidents/2025/7/27/medicine-fire/"
    ),
    CALFireIncident(
        name: "Lassen Fire",
        acresBurned: 51.0,
        percentContained: 85.0,
        isActive: true,
        startedDate: "2025-08-01",
        county: "Tehama",
        location: "Tehama Vina Road & Champlin Slough, Los Molinos",
        latitude: 40.028565,
        longitude: -122.086035,
        url: "https://www.fire.ca.gov/incidents/2025/8/1/lassen-fire/"
    ),
    CALFireIncident(
        name: "Howards Fire",
        acresBurned: 100.0,
        percentContained: 45.0,
        isActive: true,
        startedDate: "2025-07-31",
        county: "Modoc",
        location: "Highway 139 and Loveness Road, Ambrose",
        latitude: 41.48008,
        longitude: -120.957447,
        url: "https://www.fire.ca.gov/incidents/2025/7/31/howards-fire/"
    ),
    CALFireIncident(
        name: "1-4 Fire",
        acresBurned: 259.6,
        percentContained: 25.0,
        isActive: true,
        startedDate: "2025-07-31",
        county: "Lassen",
        location: "Paiute Lane and Peak Road, Susanville",
        latitude: 40.445172,
        longitude: -120.656672,
        url: "https://www.fire.ca.gov/incidents/2025/7/31/1-4-fire/"
    ),
    CALFireIncident(
        name: "4-8 Fire",
        acresBurned: 25.0,
        percentContained: 0.0,
        isActive: true,
        startedDate: "2025-08-01",
        county: "Modoc",
        location: "Kearny Road & Carson Road, California Pines",
        latitude: 41.319441,
        longitude: -120.747715,
        url: "https://www.fire.ca.gov/incidents/2025/8/1/4-8-fire/"
    ),
    CALFireIncident(
        name: "Gifford Fire ",
        acresBurned: 30519.0,
        percentContained: 5.0,
        isActive: true,
        startedDate: "2025-08-01",
        county: "San Luis Obispo, Santa Barbara",
        location: "Highway 166 Northeast of Santa Maria",
        latitude: 35.102947,
        longitude: -120.116814,
        url: "https://www.fire.ca.gov/incidents/2025/8/1/gifford-fire/"
    ),
    CALFireIncident(
        name: "Donovan Fire",
        acresBurned: 30.0,
        percentContained: 0.0,
        isActive: true,
        startedDate: "2025-08-02",
        county: "San Luis Obispo",
        location: "La Panza Road & Little Farm Road, Creston",
        latitude: 35.527328,
        longitude: -120.508946,
        url: "https://www.fire.ca.gov/incidents/2025/8/2/donovan-fire/"
    ),
    CALFireIncident(
        name: "Fremont Fire",
        acresBurned: 26.3,
        percentContained: 0.0,
        isActive: true,
        startedDate: "2025-08-02",
        county: "San Bernardino",
        location: "Near Fremontia Road and Mesquite Road",
        latitude: 34.429401,
        longitude: -117.653566,
        url: "https://www.fire.ca.gov/incidents/2025/8/2/fremont-fire/"
    ),
    CALFireIncident(
        name: "Radar Fire ",
        acresBurned: 15.0,
        percentContained: 0.0,
        isActive: true,
        startedDate: "2025-08-02",
        county: "Modoc",
        location: "Southwest of Lone Pine Lake",
        latitude: 41.7203467,
        longitude: -121.1305479,
        url: "https://www.fire.ca.gov/incidents/2025/8/2/radar-fire/"
    ),
    CALFireIncident(
        name: "Oak Fire",
        acresBurned: 45.9,
        percentContained: 0.0,
        isActive: true,
        startedDate: "2025-08-02",
        county: "Riverside",
        location: "Unknown / TBD",
        latitude: 34.003628,
        longitude: -117.162599,
        url: "https://www.fire.ca.gov/incidents/2025/8/2/oak-fire/"
    ),
    CALFireIncident(
        name: "Willow Fire",
        acresBurned: 31.5,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-19",
        county: "Madera",
        location: "At Road 600 and Road 603, Willow Creek",
        latitude: 37.118,
        longitude: -119.932289,
        url: "https://www.fire.ca.gov/incidents/2025/7/19/willow-fire/"
    ),
    CALFireIncident(
        name: "Pala Fire",
        acresBurned: 7.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-19",
        county: "San Diego",
        location: "Highway 76 and Couser Canyon Road, Pala Mesa",
        latitude: 33.342918,
        longitude: -117.114678,
        url: "https://www.fire.ca.gov/incidents/2025/7/19/pala-fire/"
    ),
    CALFireIncident(
        name: "Coulter Fire",
        acresBurned: 24.9,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-19",
        county: "El Dorado",
        location: "4200 block of Coulter Lane in Latrobe, El Dorado County",
        latitude: 38.55184,
        longitude: -121.004153,
        url: "https://www.fire.ca.gov/incidents/2025/7/19/coulter-fire/"
    ),
    CALFireIncident(
        name: "Jury Fire",
        acresBurned: 53.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-19",
        county: "Tuolumne",
        location: "At Jury Ranch Road and Outback Drive, Sonora",
        latitude: 37.916947,
        longitude: -120.356289,
        url: "https://www.fire.ca.gov/incidents/2025/7/19/jury-fire/"
    ),
    CALFireIncident(
        name: "Trap Fire",
        acresBurned: 38.3,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-20",
        county: "Mariposa",
        location: "Bear Trap Road, East of Mykleoaks Road, Mariposa",
        latitude: 37.514275,
        longitude: -120.012292,
        url: "https://www.fire.ca.gov/incidents/2025/7/20/trap-fire/"
    ),
    CALFireIncident(
        name: "Alta Fire",
        acresBurned: 17.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-20",
        county: "Butte",
        location: "Alta Airosa Drive, east of Oroville",
        latitude: 39.422347,
        longitude: -121.470538,
        url: "https://www.fire.ca.gov/incidents/2025/7/20/alta-fire/"
    ),
    CALFireIncident(
        name: "Wolfsen Fire",
        acresBurned: 1.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-21",
        county: "Merced",
        location: "Wolfsen Road and Hereford Road, Los Banos",
        latitude: 37.211668,
        longitude: -120.788745,
        url: "https://www.fire.ca.gov/incidents/2025/7/21/wolfsen-fire/"
    ),
    CALFireIncident(
        name: "Frontage Fire",
        acresBurned: 50.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-20",
        county: "San Bernardino",
        location: " E Street and Frontage Road ",
        latitude: 34.548782,
        longitude: -117.296674,
        url: "https://www.fire.ca.gov/incidents/2025/7/20/frontage-fire/"
    ),
    CALFireIncident(
        name: "Stokes Fire ",
        acresBurned: 10.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-22",
        county: "Tulare",
        location: "Orosi, North of Avenue 392",
        latitude: 36.518055,
        longitude: -119.196666,
        url: "https://www.fire.ca.gov/incidents/2025/7/22/stokes-fire/"
    ),
    CALFireIncident(
        name: "Orange Fire",
        acresBurned: 13.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-22",
        county: "Stanislaus",
        location: "Orange Blossom Road and Highway 108, Knights Ferry",
        latitude: 37.789557,
        longitude: -120.744427,
        url: "https://www.fire.ca.gov/incidents/2025/7/22/orange-fire/"
    ),
    CALFireIncident(
        name: "Euclid Fire",
        acresBurned: 120.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-23",
        county: "San Bernardino",
        location: "Highway 71 and Euclid Road, Chino Hills",
        latitude: 33.922339,
        longitude: -117.64923,
        url: "https://www.fire.ca.gov/incidents/2025/7/23/euclid-fire/"
    ),
    CALFireIncident(
        name: "Mitchell Fire",
        acresBurned: 51.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-23",
        county: "Riverside",
        location: "Bautista Road and Glasgow Road, Anza",
        latitude: 33.563156,
        longitude: -116.695847,
        url: "https://www.fire.ca.gov/incidents/2025/7/23/mitchell-fire/"
    ),
    CALFireIncident(
        name: "Posta Fire",
        acresBurned: 23.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-24",
        county: "San Diego",
        location: "La Posta Road, North of the Community of Campo",
        latitude: 32.667663,
        longitude: -116.430132,
        url: "https://www.fire.ca.gov/incidents/2025/7/24/posta-fire/"
    ),
    CALFireIncident(
        name: "4-1 Fire",
        acresBurned: 20.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-24",
        county: "Modoc",
        location: "Highway 139 north of Highway 299, Canby",
        latitude: 41.459967,
        longitude: -120.924262,
        url: "https://www.fire.ca.gov/incidents/2025/7/24/4-1-fire/"
    ),
    CALFireIncident(
        name: "Sliger Fire",
        acresBurned: 14.4,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-24",
        county: "El Dorado",
        location: "Sliger Mine Road and Hilda Way, near Middle Fork American River",
        latitude: 38.943781,
        longitude: -120.926046,
        url: "https://www.fire.ca.gov/incidents/2025/7/24/sliger-fire/"
    ),
    CALFireIncident(
        name: "Shady Fire",
        acresBurned: 52.4,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Riverside",
        location: "Avenue 54 and Shady Lane, Coachella ",
        latitude: 33.656632,
        longitude: -116.172565,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/shady-fire/"
    ),
    CALFireIncident(
        name: "Mammoth Fire ",
        acresBurned: 2533.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Modoc",
        location: "West of the Dry Lake Fire Station and Highway 139, Tionesta",
        latitude: 41.684141,
        longitude: -121.323879,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/mammoth-fire/"
    ),
    CALFireIncident(
        name: "3-5 Fire",
        acresBurned: 42.5,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Lassen",
        location: "Little Valley Road, South of Pit River Canyon Road, Little Valley",
        latitude: 40.9814,
        longitude: -121.280552,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/3-5-fire/"
    ),
    CALFireIncident(
        name: "Green Fire-RRU",
        acresBurned: 21.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Riverside",
        location: "Palisades Drive and Green River Road, Corona",
        latitude: 33.882719,
        longitude: -117.641517,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/green-fire-rru/"
    ),
    CALFireIncident(
        name: "Boneyard Fire",
        acresBurned: 227.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-26",
        county: "Tuolumne",
        location: "Priest Coulterville Road, North of Jackass Creek Road, Greeley Hill",
        latitude: 37.773371,
        longitude: -120.214807,
        url: "https://www.fire.ca.gov/incidents/2025/7/26/boneyard-fire/"
    ),
    CALFireIncident(
        name: "W-2 Fire",
        acresBurned: 24.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Modoc",
        location: "East of Payne Reservoir southeast of Alturas, Modoc County",
        latitude: 41.392519,
        longitude: -120.43839,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/w-2-fire/"
    ),
    CALFireIncident(
        name: "Pearl Fire",
        acresBurned: 39.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-25",
        county: "Kern",
        location: "Highway 178 and Elizabeth Norris Road, Lake Isabella",
        latitude: 35.6182,
        longitude: -118.48813,
        url: "https://www.fire.ca.gov/incidents/2025/7/25/pearl-fire/"
    ),
    CALFireIncident(
        name: "Hoffman Fire",
        acresBurned: 10.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-26",
        county: "Kern",
        location: "Highway 14 and Jawbone Canyon Road, Mojave",
        latitude: 35.300512,
        longitude: -118.000889,
        url: "https://www.fire.ca.gov/incidents/2025/7/26/hoffman-fire/"
    ),
    CALFireIncident(
        name: "19 Fire",
        acresBurned: 16.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-29",
        county: "Madera",
        location: "Golden State Boulevard and Road 19,  North of Fairmead  ",
        latitude: 37.07642,
        longitude: -120.202377,
        url: "https://www.fire.ca.gov/incidents/2025/7/29/19-fire/"
    ),
    CALFireIncident(
        name: "Rd 15  Madera_acres Fire",
        acresBurned: 30.0,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-30",
        county: "Madera",
        location: "Road 15, Madera",
        latitude: 36.995304,
        longitude: -120.274202,
        url: "https://www.fire.ca.gov/incidents/2025/7/30/rd-15-madera_acres-fire/"
    ),
    CALFireIncident(
        name: "Orion Fire",
        acresBurned: 24.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-07-31",
        county: "Santa Barbara",
        location: "Rancho Road & Orion Road, Vandenberg",
        latitude: 34.80493,
        longitude: -120.53608,
        url: "https://www.fire.ca.gov/incidents/2025/7/31/orion-fire/"
    ),
    CALFireIncident(
        name: "Bernardo Fire",
        acresBurned: 12.7,
        percentContained: 100.0,
        isActive: false,
        startedDate: "2025-08-01",
        county: "San Diego",
        location: "Camino Del Norte & Bernardo Center Drive ",
        latitude: 33.0088892,
        longitude: -117.0978951,
        url: "https://www.fire.ca.gov/incidents/2025/8/1/bernardo-fire/"
    ),
]
// Fire Statistics
let fireStats = FireStatistics(
    totalActiveFires: 13,
    totalAcresBurning: 72592.8,
    largestActiveFire: "Gifford Fire ",
    lastUpdated: "2025-08-02 18:56:49"
)
// MARK: - Watch Duty Style Map Interface
struct FireStatistics {
    let totalActiveFires: Int
    let totalAcresBurning: Double
    let largestActiveFire: String
    let lastUpdated: String
}
struct DynamicFireMarker: View {
    let fire: CALFireIncident
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Dynamic glow based on fire size
                if fire.acresBurned > 10000 {
                    Circle()
                        .fill(getFireColor().opacity(0.4))
                        .frame(width: getMarkerSize() + 20, height: getMarkerSize() + 20)
                        .blur(radius: 8)
                }
                
                // Main marker
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [getFireColor(), getFireColor().opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: getMarkerSize(), height: getMarkerSize())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(color: .black.opacity(0.3), radius: 1)
                    )
                    .shadow(color: getFireColor().opacity(0.6), radius: 6, x: 0, y: 3)
                
                // Fire icon
                Image(systemName: "flame.fill")
                    .font(.system(size: getIconSize(), weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getMarkerSize() -> CGFloat {
        if fire.acresBurned > 10000 { return 36 }
        else if fire.acresBurned > 1000 { return 30 }
        else if fire.acresBurned > 100 { return 26 }
        else { return 22 }
    }
    
    private func getIconSize() -> CGFloat {
        if fire.acresBurned > 10000 { return 16 }
        else if fire.acresBurned > 1000 { return 14 }
        else if fire.acresBurned > 100 { return 12 }
        else { return 10 }
    }
    
    private func getFireColor() -> Color {
        if !fire.isActive { return .gray }
        if fire.percentContained < 30 { return .red }
        else if fire.percentContained < 70 { return .orange }
        else { return .yellow }
    }
}
struct FireDetailCard: View {
    let fire: CALFireIncident
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with fire name and size
            VStack(spacing: 8) {
                HStack {
                    Text(fire.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundColor(.wsOrange)
                }
                
                Text("\(Int(fire.acresBurned)) acres")
                    .font(.headline)
                    .foregroundColor(.wsYellow)
            }
            .padding()
            .background(Color.wsDark.opacity(0.8))
            
            // Fire details
            ScrollView {
                VStack(spacing: 16) {
                    // Status indicator
                    HStack {
                        Circle()
                            .fill(fire.isActive ? Color.wsRed : Color.wsOrange)
                            .frame(width: 12, height: 12)
                        Text(fire.isActive ? "Active Fire" : "Contained")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Details grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        DetailItem(title: "Containment", value: "\(Int(fire.percentContained))%", icon: "percent")
                        DetailItem(title: "Started", value: fire.startedDate, icon: "calendar")
                        DetailItem(title: "County", value: fire.county, icon: "mappin.and.ellipse")
                        DetailItem(title: "Location", value: fire.location, icon: "location.fill")
                    }
                    .padding(.horizontal)
                    
                    // CAL FIRE link
                    if !fire.url.isEmpty {
                        Button("View on CAL FIRE Website") {
                            if let url = URL(string: fire.url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.wsOrange)
                        .padding()
                        .background(Color.wsOrange.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(Color.wsDark)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}
struct DetailItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.wsOrange)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.wsDark.opacity(0.6))
        .cornerRadius(8)
    }
}
/* struct WildfireMap: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fireDataService = FireDataService()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var region: MKCoordinateRegion? = nil
    @State private var showLocationError = false
    @State private var selectedCALFire: CALFireIncident? = nil
    @State private var selectedFilter: FireFilter = .all
    @State private var showFilters = false
    @State private var isLoading = false
    @State private var lastUpdateTime = Date()
    
    
    // Performance optimization: Cache filtered fires
    @State private var filteredFires: [CALFireIncident] = []
    var body: some View {
        ZStack {
            backgroundView
            mapView
            controlsView
        }
        .background(backgroundView)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedCALFire) { fire in
            FireDetailCard(fire: fire)
        }
        .alert("Location Access Required", isPresented: $showLocationError) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to see nearby fires.")
        }
        .onAppear {
            setupInitialMapPosition()
            updateFilteredFires()
        }
        .onChange(of: selectedFilter) { _, _ in
            updateFilteredFires()
        }
        .onChange(of: fireDataService.calFireIncidents) { _, _ in
            updateFilteredFires()
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(gradient: Gradient(colors: [.wsDark, .wsOrange.opacity(0.15)]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea(.all, edges: .all)
    }
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            // Show user location with simplified marker
            if let location = locationManager.location {
                UserAnnotation()
                Annotation("Your Location", coordinate: location.coordinate) {
                    simplifiedUserMarker
                }
            }
            
            // Show filtered CAL FIRE incidents with Watch Duty-style markers
            ForEach(filteredFires, id: \.id) { fire in
                Annotation(fire.name, coordinate: fire.coordinate) {
                    DynamicFireMarker(fire: fire) {
                        handleCALFireTap(fire)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .accessibilityLabel("Wildfire Map")
        .onAppear {
            setupInitialMapPosition()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation, cameraPosition == .automatic {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                )
                cameraPosition = .region(region)
            }
        }
        .onMapCameraChange { context in
            region = context.region
        }
    }
    
    // Simplified user marker for better performance
    private var simplifiedUserMarker: some View {
        ZStack {
            Circle()
                .fill(Color.wsOrange)
                .frame(width: 20, height: 20)
                .overlay(Circle().stroke(.white, lineWidth: 2))
            
            Image(systemName: "location.fill")
                .foregroundColor(.white)
                .font(.caption2.bold())
        }
    }
    
    private var controlsView: some View {
        VStack {
            topControls
            Spacer()
            bottomControls
        }
    }
    
    // MARK: - UI Components
    
    private var topControls: some View {
        VStack(spacing: 12) {
            // Fire Statistics Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Fires: \(fireStats.totalActiveFires)")
                        .font(.caption.bold())
                        .foregroundColor(.wsRed)
                    Text("\(Int(fireStats.totalAcresBurning)) acres burning")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Largest: \(fireStats.largestActiveFire)")
                        .font(.caption.bold())
                        .foregroundColor(.wsOrange)
                    Text("Updated: \(timeAgoString(from: lastUpdateTime))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.wsDark.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Status bar
            HStack {
                // Update status
                HStack(spacing: 8) {
                    Circle()
                        .fill(isLoading ? Color.wsOrange : Color.wsYellow)
                        .frame(width: 8, height: 8)
                    
                    Text(isLoading ? "Updating..." : "Last updated \(timeAgoString(from: lastUpdateTime))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Filter button
                Button(action: { showFilters.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title3)
                        Text(selectedFilter.displayName)
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.wsDark.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.wsOrange.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 16)
            
            // Filter panel
            if showFilters {
                filterPanel
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private var filterPanel: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ForEach(FireFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFilters = false
                        }
                    }) {
                        Text(filter.displayName)
                            .font(.caption.bold())
                            .foregroundColor(selectedFilter == filter ? .wsDark : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedFilter == filter ? Color.wsOrange : Color.wsDark.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.wsDark.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
    
    private var bottomControls: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Zoom controls on the right
                VStack(spacing: 12) {
                    Button(action: {
                        zoomMap(by: 0.5)
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title2)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.wsDark.opacity(0.8))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.wsOrange.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        zoomMap(by: 2.0)
                    }) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title2)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.wsDark.opacity(0.8))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.wsOrange.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 100) // Account for navigation bar
            }
        }
    }
    // MARK: - Helper Methods
    
    private func updateFilteredFires() {
        switch selectedFilter {
        case .all:
            filteredFires = fireDataService.calFireIncidents
        case .active:
            filteredFires = fireDataService.calFireIncidents.filter { $0.isActive }
        case .highThreat:
            filteredFires = fireDataService.calFireIncidents.filter { $0.isActive && $0.percentContained < 30 }
        case .contained:
            filteredFires = fireDataService.calFireIncidents.filter { !$0.isActive }
        }
    }
    
    private func handleCALFireTap(_ fire: CALFireIncident) {
        selectedCALFire = fire
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    private func setupInitialMapPosition() {
        // Request location permission immediately
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermission()
        }
        
        // Set initial map position based on current authorization status
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
                )
                cameraPosition = .region(region)
            } else {
                // If we have permission but no location yet, start with automatic
                cameraPosition = .automatic
            }
        case .denied, .restricted:
            showLocationError = true
            fallbackToDefaultRegion()
        case .notDetermined:
            // Start with automatic while waiting for permission response
            cameraPosition = .automatic
        @unknown default:
            fallbackToDefaultRegion()
        }
    }
    private func fallbackToDefaultRegion() {
        // Default to western US view
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -118.5795),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
        cameraPosition = .region(defaultRegion)
    }
    private func recenterToUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
            )
            withAnimation {
                cameraPosition = .region(region)
            }
        }
    }
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Dynamic fire marker based on fire size and status
    private func optimizedFireMarker(for fire: CALFireIncident) -> some View {
        let color = getCALFireMarkerColor(for: fire)
        let markerSize = getMarkerSize(for: fire)
        let iconSize = getIconSize(for: fire)
        
        return ZStack {
            // Outer glow effect for larger fires
            if fire.acresBurned > 1000 {
                Circle()
                    .fill(color.opacity(0.4))
                    .frame(width: markerSize + 20, height: markerSize + 20)
                    .blur(radius: 8)
            }
            
            // Middle glow layer for medium+ fires
            if fire.acresBurned > 100 {
                Circle()
                    .fill(color.opacity(0.6))
                    .frame(width: markerSize + 12, height: markerSize + 12)
                    .blur(radius: 4)
            }
            
            // Main marker with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: markerSize, height: markerSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: fire.acresBurned > 1000 ? 3 : 2)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                )
                .shadow(color: color.opacity(0.7), radius: 6, x: 0, y: 3)
            
            // Fire icon with dynamic sizing
            Image(systemName: "flame.fill")
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1)
        }
        .accessibilityLabel("\(fire.name) - \(fire.isActive ? "Active" : "Contained") fire - \(Int(fire.acresBurned)) acres")
    }
    
    // Helper functions for dynamic sizing
    private func getMarkerSize(for fire: CALFireIncident) -> CGFloat {
        if fire.acresBurned > 10000 {
            return 36 // Very large fires (reduced from 48)
        } else if fire.acresBurned > 1000 {
            return 30 // Large fires (reduced from 36)
        } else if fire.acresBurned > 100 {
            return 26 // Medium fires (reduced from 28)
        } else {
            return 22 // Small fires (increased from 20)
        }
    }
    
    private func getIconSize(for fire: CALFireIncident) -> CGFloat {
        if fire.acresBurned > 10000 {
            return 16 // Very large fires (reduced from 20)
        } else if fire.acresBurned > 1000 {
            return 14 // Large fires (reduced from 16)
        } else if fire.acresBurned > 100 {
            return 12 // Medium fires (reduced from 14)
        } else {
            return 10 // Small fires (kept same)
        }
    }
    
    private func getCALFireMarkerColor(for fire: CALFireIncident) -> Color {
        if fire.isActive {
            if fire.percentContained < 30 {
                return Color.red
            } else if fire.percentContained < 70 {
                return Color.orange
            } else {
                return Color.yellow
            }
        } else {
            return Color.gray
        }
    }
    
    private func zoomMap(by factor: Double) {
        guard let currentRegion = region else {
            print("Cannot zoom, region is not available.")
            return
        }
        let newSpan = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta * factor,
            longitudeDelta: currentRegion.span.longitudeDelta * factor
        )
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        cameraPosition = .region(newRegion)
        region = newRegion
    }
}
// MARK: - Fire Filter Enum
enum FireFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case highThreat = "High Threat"
    case contained = "Contained"
    
    var displayName: String {
        switch self {
        case .all: return "All Fires"
        case .active: return "Active"
        case .highThreat: return "High Threat"
        case .contained: return "Contained"
        }
    }
}
// MARK: - CAL FIRE Details View - Optimized
struct CALFireDetailsView: View {
    let fire: CALFireIncident
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(gradient: Gradient(colors: [.wsDark, .wsOrange.opacity(0.15)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .font(.title)
                                    .foregroundColor(.wsOrange)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fire.name)
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    
                                    Text(getCALFireThreatLevel(for: fire))
                                        .font(.subheadline)
                                        .foregroundColor(.wsYellow)
                                }
                                
                                Spacer()
                                
                                Button("Done") {
                                    dismiss()
                                }
                                .foregroundColor(.wsOrange)
                            }
                            
                            // Status indicator
                            HStack {
                                Circle()
                                    .fill(fire.isActive ? Color.wsRed : Color.wsOrange)
                                    .frame(width: 12, height: 12)
                                
                                Text(fire.isActive ? "Active Fire" : "Contained Fire")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.wsDark.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Fire details
                        VStack(spacing: 16) {
                            detailRow(title: "Acres Burned", value: "\(Int(fire.acresBurned)) acres", icon: "flame.fill")
                            detailRow(title: "Containment", value: "\(Int(fire.percentContained))%", icon: "percent")
                            detailRow(title: "Started", value: fire.startedDate, icon: "calendar")
                            detailRow(title: "County", value: fire.county, icon: "mappin.and.ellipse")
                            detailRow(title: "Location", value: fire.location, icon: "location.fill")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.wsDark.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Location info
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.wsOrange)
                                Text("Coordinates")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text("Latitude: \(String(format: "%.4f", fire.coordinate.latitude))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Longitude: \(String(format: "%.4f", fire.coordinate.longitude))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.wsDark.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // CAL FIRE link
                        if !fire.url.isEmpty {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.wsOrange)
                                    Text("More Information")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                Button("View on CAL FIRE Website") {
                                    if let url = URL(string: fire.url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .foregroundColor(.wsOrange)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.wsOrange.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.wsOrange.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.wsDark.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.wsOrange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.wsOrange)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }
    
    private func getCALFireThreatLevel(for fire: CALFireIncident) -> String {
        if !fire.isActive {
            return "Contained"
        }
        
        let containment = fire.percentContained
        if containment >= 70 {
            return "Low Threat (\(Int(containment))% contained)"
        } else if containment >= 30 {
            return "Moderate Threat (\(Int(containment))% contained)"
        } else {
            return "High Threat (\(Int(containment))% contained)"
        }
    }
    
}
// Preview-safe version of WildfireMap
struct WildfireMapPreview: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var region: MKCoordinateRegion? = nil
    @State private var showLocationError = false
    @State private var selectedCALFire: CALFireIncident? = nil
    @State private var selectedFilter: FireFilter = .all
    @State private var showFilters = false
    @State private var isLoading = false
    @State private var lastUpdateTime = Date()
    
    // Mock data for preview - no network calls
    @State private var filteredFires: [CALFireIncident] = [
        CALFireIncident(
            name: "Preview Fire",
            acresBurned: 1250.0,
            percentContained: 45.0,
            isActive: true,
            startedDate: "2025-01-15T10:30:00Z",
            county: "Los Angeles",
            location: "Near Malibu",
            latitude: 34.0259,
            longitude: -118.7798,
            url: "https://preview.fire.ca.gov"
        ),
        CALFireIncident(
            name: "Mock Contained Fire",
            acresBurned: 850.0,
            percentContained: 100.0,
            isActive: false,
            startedDate: "2025-01-10T08:15:00Z",
            county: "Ventura",
            location: "Near Oxnard",
            latitude: 34.1975,
            longitude: -119.1771,
            url: "https://preview.fire.ca.gov"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fire gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.05),
                        Color(red: 0.2, green: 0.1, blue: 0.05),
                        Color(red: 0.15, green: 0.05, blue: 0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Map(position: $cameraPosition) {
                    ForEach(filteredFires, id: \.id) { fire in
                        Annotation(fire.name, coordinate: CLLocationCoordinate2D(latitude: fire.latitude, longitude: fire.longitude)) {
                            Button(action: {
                                selectedCALFire = fire
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(fire.isActive ? Color.red : Color.orange)
                                        .frame(width: 20, height: 20)
                                    
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                }
                .mapStyle(.hybrid)
            }
            .navigationTitle("Fire Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    Text("Map preview disabled")
}
*/

