//
//  Item.swift
//  Ignis
//
//  Created by Areen Jain on 7/20/25.
//
import Foundation
import SwiftData
/// Represents an item in the Ignis application
/// This model demonstrates SwiftData best practices
@Model
final class Item {
    // MARK: - Properties
    
    /// The timestamp when this item was created
    var timestamp: Date
    
    /// A computed property for formatted timestamp
    var formattedTimestamp: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
    
    /// A computed property to check if item is recent (within last 24 hours)
    var isRecent: Bool {
        Calendar.current.isDateInToday(timestamp)
    }
    
    // MARK: - Initialization
    
    /// Creates a new item with the current timestamp
    init() {
        self.timestamp = Date()
    }
    
    /// Creates a new item with a specific timestamp
    /// - Parameter timestamp: The creation timestamp
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

