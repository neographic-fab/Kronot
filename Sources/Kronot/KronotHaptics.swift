//
//  KronotHaptics.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Handles haptic feedback for Kronot interactions.
@MainActor
final class KronotHaptics {
    private let selection = UISelectionFeedbackGenerator()
    
    /// Prepares the feedback generator to reduce latency.
    func prepare() {
        selection.prepare()
    }
    
    /// Emits a selection feedback event and prepares the generator for the next one.
    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }
}
