//
//  PerformanceListView.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

struct PerformanceListView: View {
    @State private var showingAddPerformance = false
    @StateObject private var vm = PerformanceListViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            Picker("Filter", selection: $vm.filter) {
                Text("filter_all").tag(PerformanceListViewModel.Filter.all)
                Text("filter_local").tag(PerformanceListViewModel.Filter.local)
                Text("filter_remote").tag(PerformanceListViewModel.Filter.remote)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.filtered.isEmpty {
                Text("performance_list_empty")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vm.filtered) { p in
                        PerformanceRow(performance: p)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("performance_list_title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddPerformance = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPerformance) {
            NavigationStack {
                AddPerformanceView(onSave: {
                    Task { await vm.load() }
                })
            }
        }
        .task {
            await vm.load()
        }
        .onChange(of: scenePhase) { new in
            if new == .active {
                Task { await vm.load() }
            }
        }
    }
}
