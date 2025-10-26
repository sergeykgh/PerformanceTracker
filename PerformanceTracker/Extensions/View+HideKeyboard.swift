//
//  File.swift
//  PerformanceTracker
//
//  Created by Sergey on 26.10.2025.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
