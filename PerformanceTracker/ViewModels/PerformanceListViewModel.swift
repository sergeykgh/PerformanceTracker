//
//  PerformanceListViewModel.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

@MainActor
final class PerformanceListViewModel: ObservableObject {
    @Published private(set) var performances: [Performance] = []
    @Published var filter: Filter = .all
    @Published var isLoading = false
    @Published var errorMessage: String?

    enum Filter {
        case all, local, remote
    }

    private let localStore: PerformanceStore
    private let remoteStore: PerformanceStore

    init(local: PerformanceStore = CoreDataPerformanceStore(), remote: PerformanceStore = FirebasePerformanceStore()) {
        self.localStore = local
        self.remoteStore = remote
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let local = try await localStore.fetchAll()
            let remote = try await remoteStore.fetchAll()
            performances = (local + remote).sorted { $0.date > $1.date }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    var filtered: [Performance] {
        switch filter {
        case .all: return performances
        case .local: return performances.filter { $0.storage == .local }
        case .remote: return performances.filter { $0.storage == .remote }
        }
    }
}
