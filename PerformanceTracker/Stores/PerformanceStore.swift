//
//  PerformanceStore.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

protocol PerformanceStore {
    func fetchAll() async throws -> [Performance]
    func save(_ performance: Performance) async throws
}
