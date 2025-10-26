//
//  PerformanceRow.swift
//  PerformanceTracker
//
//  Created by Sergey on 25.10.2025.
//

import SwiftUI

fileprivate enum Constants {
    static let localRecordColor = Color(red: 0.4, green: 0.9, blue: 0.7)
    static let remoteRecordColor = Color(red: 0.4, green: 0.7, blue: 0.9)
}

struct PerformanceRow: View {
    let performance: Performance

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(performance.title)
                    .font(.headline)
                Text(performance.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(String(format: "%.0f min", performance.durationMinutes))
                    .bold()
                Text(dateFormatter.string(from: performance.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(performance.storage == .local ? Constants.localRecordColor : Constants.remoteRecordColor)
        .cornerRadius(8)
    }
}

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()
