//
//  AddPerformanceViewModel.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

@MainActor
final class AddPerformanceViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var location: String = ""
    @Published var durationMinutes: String = ""
    @Published var storageChoice: StorageType = .local
    @Published var isSaving = false
    @Published var saveError: String?

    private let localStore: PerformanceStore
    private let remoteStore: PerformanceStore

    init(local: PerformanceStore = CoreDataPerformanceStore(), remote: PerformanceStore = FirebasePerformanceStore()) {
        self.localStore = local
        self.remoteStore = remote
    }

    func save() async -> Bool {
        guard let duration = dataValidation() else {
            return false
        }

        isSaving = true
        saveError = nil
        let perf = Performance(title: title, location: location, durationMinutes: duration, storage: storageChoice)
        do {
            switch storageChoice {
            case .local: try await localStore.save(perf)
            case .remote: try await remoteStore.save(perf)
            default: break
            }
            isSaving = false
            return true
        } catch {
            isSaving = false
            saveError = error.localizedDescription
            return false
        }
    }
    
    func dataValidation() -> Double? {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            saveError = NSLocalizedString("error_empty_title", comment: "")
            return nil
        }
        guard !location.trimmingCharacters(in: .whitespaces).isEmpty else {
            saveError = NSLocalizedString("error_empty_location", comment: "")
            return nil
        }
        guard let duration = Double(durationMinutes), duration > 0 else {
            saveError = NSLocalizedString("error_invalid_duration", comment: "")
            return nil
        }
        
        return duration
    }
}
