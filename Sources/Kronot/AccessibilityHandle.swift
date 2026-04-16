//
//  AccessibilityHandle.swift
//  Kronot
//
//  Created by Fabio Floris on 14/04/2026.
//

import SwiftUI

/// Invisible element used to improve the accessible tap area of a drag handle.
///
/// `AccessibilityHandle` exposes a circular area sized appropriately for the platform,
/// making it easier for VoiceOver to identify and interact with a single reference.
///
/// - Note: This view does not intercept input events (`allowsHitTesting(false)`).
///   Its role is limited to accessibility and layout support.
struct AccessibilityHandle: View {
    private let reference: RangeReference
    private let layout: RadialLayout
    private let fraction: Double
    
    @Environment(\.designTokens) private var tokens
    
    /// Creates an accessibility handle for the specified reference.
    ///
    /// - Parameters:
    ///   - reference: The reference to expose to VoiceOver, either start or end.
    ///   - layout: Radial layout used to compute the handle position.
    ///   - fraction: Fraction of the day used to place the handle on the dial.
    init(for reference: RangeReference, in layout: RadialLayout, relativeTo fraction: Double) {
        self.reference = reference
        self.layout = layout
        self.fraction = fraction
    }
    
    /// Polar offset of the handle relative to the center of the dial.
    ///
    /// The radius and angle are derived from the current `layout`
    /// and environment `tokens`.
    private var offset: CGSize {
        let angle = layout.angle(for: fraction)
        let radius = layout.thumbRadius(using: tokens)
        return .init(
            width: cos(angle.radians) * radius,
            height: sin(angle.radians) * radius
        )
    }
    
    /// Exposes a circular accessibility area around the current handle position.
    ///
    /// The area is visually transparent, but contributes to the accessibility tree
    /// when combined with the modifiers applied by `Kronot`.
    var body: some View {
        Circle()
            .fill(.clear)
            .frame(width: 44, height: 44)
            .contentShape(.circle)
            .offset(offset)
            .allowsHitTesting(false)
    }
}
