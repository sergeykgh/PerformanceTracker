//
//  Performance.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

enum StorageType: String, Codable {
    case local
    case remote
    case unknown
}

struct Performance: Identifiable, Codable {
    let id: UUID
    var title: String
    var location: String
    var durationMinutes: Double
    var date: Date
    var storage: StorageType

    init(id: UUID = UUID(), title: String, location: String, durationMinutes: Double, date: Date = Date(), storage: StorageType) {
        self.id = id
        self.title = title
        self.location = location
        self.durationMinutes = durationMinutes
        self.date = date
        self.storage = storage
    }
}
