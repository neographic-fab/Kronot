//
//  ThumbView.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Draggable handle view used for the start and end references.
///
/// `ThumbView` derives size, position, and appearance from `DesignTokens`
/// and `RadialLayout`.
/// Icon and shadow rendering are optional and driven by the configured token values.
struct ThumbView: View {
    let reference: RangeReference
    let layout: RadialLayout
    let fraction: Double
    
    @Environment(\.designTokens) private var tokens
    
    /// Resolved handle appearance for the current reference.
    var thumb: DesignTokens.ThumbTokens.Appearance {
        switch reference {
        case .start: return tokens.thumb.start
        case .end: return tokens.thumb.end
        }
    }
    
    /// Draws a circular handle positioned on the dial according to the given fraction.
    var body: some View {
        // Computes the handle size and its polar position on the dial.
        let trackWidth = tokens.track.lineWidth
        let rawSize = trackWidth * thumb.scale.factor
        let thumbSize = rawSize.clamped(to: 1.0...trackWidth)
        let angle = layout.angle(for: fraction)
        let radius = layout.thumbRadius(using: tokens)
        let offset = CGSize(
            width: cos(angle.radians) * radius,
            height: sin(angle.radians) * radius
        )
        
        Circle()
            .fill(thumb.color)
            .frame(width: thumbSize, height: thumbSize)
            .shadowIf(
                thumb.showShadow,
                color: thumb.shadowColor,
                radius: thumb.shadowRadius,
                offset: thumb.shadowOffset
            )
            .overlay {
                if thumb.showIcon {
                    Image(systemName: thumb.iconSystemName)
                        .foregroundStyle(thumb.iconColor)
                        .font(.system(size: thumbSize * 0.8, weight: .medium))
                }
            }
            .offset(offset)
            .accessibilityHidden(true)
    }
}

private extension View {
    /// Applies a shadow only when the given condition is `true`.
    ///
    /// Example:
    /// ```swift
    /// Circle()
    ///     .shadowIf(
    ///         showShadow,
    ///         color: .black.opacity(0.2),
    ///         radius: 4,
    ///         offset: .init(x: 0, y: 2)
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - condition: Boolean condition that enables shadow rendering.
    ///   - color: Shadow color.
    ///   - radius: Shadow blur radius.
    ///   - offset: Shadow offset on the x and y axes.
    /// - Returns: The original view, with shadow applied only when `condition` is `true`.
    @ViewBuilder
    func shadowIf(_ condition: Bool, color: Color, radius: CGFloat, offset: CGPoint) -> some View {
        if condition {
            self.shadow(color: color, radius: radius, x: offset.x, y: offset.y)
        } else {
            self
        }
    }
}
