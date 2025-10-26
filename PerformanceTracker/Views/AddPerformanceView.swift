//
//  AddPerformanceView.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

struct AddPerformanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddPerformanceViewModel()
    var onSave: (() -> Void)?

    var body: some View {
        Form {
            Section(header: Text("section_general_info")) {
                TextField("title_placeholder", text: $vm.title)
                TextField("location_placeholder", text: $vm.location)
                TextField("duration_placeholder", text: $vm.durationMinutes)
                    .keyboardType(.decimalPad)
            }
            
            if vm.isSaving {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("saving_message")
                        Spacer()
                    }
                }
            }

            Section(header: Text("section_storage")) {
                Picker("", selection: $vm.storageChoice) {
                    Text("storage_local").tag(StorageType.local)
                    Text("storage_remote").tag(StorageType.remote)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if let err = vm.saveError {
                Section { Text(err).foregroundColor(.red) }
            }
        }
        .navigationTitle("add_performance_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("cancel_button") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { Task { await saveTapped() } }) { Text("save_button") }
            }
        }
        .onTapGesture { hideKeyboard() }
    }

    private func saveTapped() async {
        let ok = await vm.save()
        if ok {
            onSave?()
            dismiss()
        }
    }
}
