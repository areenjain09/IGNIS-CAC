//
//  IgnisApp.swift
//  Ignis
//
//  Created by Areen Jain on 7/20/25.
//

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Main Navigation View - Optimized for Performance
struct MainNavigationView: View {
    @State private var selectedTab = 2 // Home is selected by default
    @State private var showLandingPage = true // Start with landing page
    @State private var showSideMenu = false
    @State private var showBottomNavBar = true
    
    var body: some View {
        if showLandingPage {
                // Landing page without navigation bar
                LandingPageView(onStartNow: {
                    withAnimation(.easeInOut(duration: 0.3)) { // Reduced animation duration
                        showLandingPage = false
                    }
                })
            } else {
                // Main app with navigation bar
                ZStack {
                    // Background - Pure black
                    Color.black
                        .ignoresSafeArea(.all, edges: .all)
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0: // Chat
                            WildfireChatbotView()
                        case 1: // Mental Health
                            MentalHelpView()
                        case 2: // Home
                            HomePageView()
                        case 3: // Education
                            EducationView()
                        case 4: // Wildfire Map
                            WildfireMap()
                        case 5: // Community
                            CommunityThreadsView()
                        case 6: // Resources
                            ResourcesView()
                        case 7: // Legislative
                            LegislativeView()
                        default:
                            HomePageView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    
                    // Custom Floating Navigation Bar
                    if showBottomNavBar {
                        VStack {
                            Spacer()
                            CustomFloatingNavBar(selectedTab: $selectedTab)
                        }
                    }
                    
                    // Side Menu Overlay
                    if showSideMenu {
                        SideMenuView(
                            showSideMenu: $showSideMenu,
                            selectedTab: $selectedTab
                        )
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToTab"))) { notification in
                    if let tabIndex = notification.userInfo?["tabIndex"] as? Int {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tabIndex
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HideBottomNavBar"))) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showBottomNavBar = false
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowBottomNavBar"))) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showBottomNavBar = true
                    }
                }
            }
    }
}

// MARK: - Side Menu View
struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @Binding var selectedTab: Int
    
    let menuItems = [
        ("Home", "house.fill", 2),
        ("Chatbot", "message.fill", 0),
        ("Mental Health", "heart.fill", 1),
        ("Education", "book.fill", 3),
        ("Wildfire Map", "map.fill", 4),
        ("Community", "person.3.fill", 5),
        ("Resources", "gift.fill", 6),
        ("Legislative", "building.columns.fill", 7)
    ]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSideMenu = false
                    }
                }
            
            // Menu content
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ignis")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.wsOrange)
                        
                        Text("Wildfire Safety")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // Menu items
                    VStack(spacing: 0) {
                        ForEach(menuItems, id: \.0) { item in
                            MenuItemView(
                                title: item.0,
                                icon: item.1,
                                isSelected: selectedTab == item.2,
                                action: {
                                    if item.2 >= 0 {
                                        selectedTab = item.2
                                    }
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSideMenu = false
                                    }
                                }
                            )
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 280)
                .background(
                    Color(red: 0.05, green: 0.05, blue: 0.05)
                )
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(.wsOrange.opacity(0.3)),
                    alignment: .trailing
                )
                
                Spacer()
            }
        }
    }
}

// MARK: - Menu Item View
struct MenuItemView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .wsOrange : .gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .wsOrange : .white)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(Color.wsOrange)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .wsOrange.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Lazy View for Performance
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

// MARK: - Custom Floating Navigation Bar - Optimized
struct CustomFloatingNavBar: View {
    @Binding var selectedTab: Int
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            // Chatbot Button (Left)
            NavBarButton(
                icon: "message.fill",
                title: "Chat",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            // Mental Health Button
            NavBarButton(
                icon: "heart.fill",
                title: "Mental",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            // Home Button (Center)
            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { // Reduced animation duration
                    selectedTab = 2
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // Reduced delay
                    isPressed = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.wsOrange, .wsRed]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .shadow(color: .wsOrange.opacity(0.4), radius: 6, x: 0, y: 3)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                    
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel("Home")
            
            // Education Button
            NavBarButton(
                icon: "book.fill",
                title: "Learn",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            
            // Map Button
            NavBarButton(
                icon: "map.fill",
                title: "Map",
                isSelected: selectedTab == 4,
                action: { selectedTab = 4 }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.wsOrange.opacity(0.3), .wsRed.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
}

// MARK: - Optimized Nav Bar Button
struct NavBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { // Reduced animation duration
                action()
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // Reduced delay
                isPressed = false
            }
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .wsOrange : .white.opacity(0.8))
                    .scaleEffect(isPressed ? 0.8 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .wsOrange : .white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "Selected" : "Not selected")
    }
}

@main
struct IgnisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Initialize notification service
        NotificationService.shared.setupNotificationCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            MainNavigationView()
        }
    }
}

// MARK: - Optimized App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }
    
    // Handle remote notification registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Here you would send the token to your server for remote notifications
        // For now, we'll just print it
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // Handle remote notifications when app is in background
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Handle the remote notification
        if let aps = userInfo["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: Any] {
                let title = alert["title"] as? String ?? "Wildfire Alert"
                let body = alert["body"] as? String ?? "Emergency notification"
                
                // Schedule a local notification to show the content
                NotificationService.shared.scheduleEmergencyAlert(
                    title: title,
                    body: body,
                    fireLocation: userInfo["fireLocation"] as? String ?? "Unknown Location"
                )
            }
        }
        
        completionHandler(.newData)
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        _ = response.notification.request.content.userInfo // silences unused warning
        
        // Handle different notification types
        switch response.notification.request.content.categoryIdentifier {
        case "EMERGENCY_ALERT":
            NotificationCenter.default.post(name: .navigateToMap, object: nil)
        case "EVACUATION_ALERT":
            NotificationCenter.default.post(name: .navigateToEvacuation, object: nil)
        case "COMMUNITY_POST":
            NotificationCenter.default.post(name: .navigateToCommunity, object: nil)
        default:
            break
        }
        
        completionHandler()
    }
}
