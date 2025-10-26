//
//  FirebasePerformanceStore.swift
//  PerfomanceTracker
//
//  Created by Sergey on 23.10.2025.
//

import FirebaseCore
import FirebaseFirestore

final class FirebasePerformanceStore: PerformanceStore {
    private let db = Firestore.firestore()
    private let collection = "performances"
    
    func fetchAll() async throws -> [Performance] {
        let snapshot = try await db.collection(collection)
            .getDocuments()
        return try snapshot.documents.compactMap { doc in
            return try doc.data(as: Performance.self)
        }
    }

    func save(_ performance: Performance) async throws {
        try db.collection(collection)
            .document(performance.id.uuidString)
            .setData(from: performance)
    }
}
