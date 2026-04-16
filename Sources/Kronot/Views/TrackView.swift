//
//  TrackView.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Internal shape used to draw either the full track or the active range arc.
///
/// `TrackShape` does not contain styling logic.
/// It receives resolved angles and layout information, and only draws
/// the corresponding arc path.
private struct TrackShape: InsettableShape {
    
    /// Role of the shape: full track or active range arc.
    enum Role {
        /// Draws the full circular track.
        case base
        
        /// Draws the active range segment.
        ///
        /// Fractions are expected in the `0...1` range and are converted to angles
        /// through `layout.angle(for:)`.
        /// The arc is drawn counterclockwise.
        case range(_ startFraction: Double, _ endFraction: Double)
    }
    
    let role: Role
    let layout: RadialLayout
    var insetAmount: CGFloat = .zero
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
    
    /// Builds the arc path using the resolved angles and inset amount.
    func path(in rect: CGRect) -> Path {
        let angles = resolvedAngles()
        var path = Path()
        path.addArc(
            center: layout.center,
            radius: layout.radius(insetBy: insetAmount),
            startAngle: angles.start,
            endAngle: angles.end,
            clockwise: false
        )
        return path
    }
}

private extension TrackShape {
    
    // MARK: - Angle Resolution
    
    /// Returns the effective angles used to draw the shape.
    ///
    /// - For the full track, the arc covers the complete dial (`0 → 1`).
    /// - For the active range, start and end angles are derived from the provided
    ///   `0...1` fractions through `layout.angle(for:)`, and the arc is drawn
    ///   counterclockwise between them.
    ///
    /// - Returns: The start and end angles used to build the arc path.
    func resolvedAngles() -> (start: Angle, end: Angle) {
        switch role {
        case .base:
            return (start: layout.angle(for: .zero), end: layout.angle(for: 1.0))
            
        case let .range(startFraction, endFraction):
            let startAngle = layout.angle(for: startFraction)
            let endAngle = layout.angle(for: endFraction)
            return (start: startAngle, end: endAngle)
        }
    }
}

/// Composes the visual track layer and the active range arc.
///
/// `TrackView` reads dimensions and styling from `DesignTokens`
/// and resolves angles through `RadialLayout`.
struct TrackView: View {
    let layout: RadialLayout
    let fractions: (RangeReference) -> Double
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    var body: some View {
        Group {
            TrackShape(role: .base, layout: layout)
                .inset(by: tokens.track.inset)
                .strokeBorder(baseShapeStyle, style: strokeStyle)
                
            TrackShape(role: .range(fractions(.start), fractions(.end)), layout: layout)
                .inset(by: tokens.track.inset)
                .strokeBorder(rangeShapeStyle, style: strokeStyle)
                .overlay {
                    if tokens.track.showMarker || differentiateWithoutColor {
                        TrackMarker(layout: layout, fractions: fractions)
                    }
                }
        }
        .accessibilityHidden(true)
    }
}

private extension TrackView {
    
    // MARK: - Stroke Configuration
    
    /// Shared stroke style used by both the base track and the active range.
    var strokeStyle: StrokeStyle {
        .init(lineWidth: tokens.track.lineWidth, lineCap: tokens.track.lineCap)
    }
    
    // MARK: - Angle Resolution
    
    /// Angles used to draw the full track (`0 → 360°`).
    var trackAngles: (start: Angle, end: Angle) {
        let start = layout.zeroAngle
        let end = start + .degrees(360.0)
        return (start, end)
    }
    
    /// Angles used to draw the active range, derived from the current fractions.
    var rangeAngles: (start: Angle, end: Angle) {
        let start = layout.angle(for: fractions(.start))
        var delta = fractions(.end) - fractions(.start)

        if delta < .zero { delta += 1 }

        let end = start + .degrees(360.0 * delta)
        return (start, end)
    }
    
    // MARK: - Shape Style Resolution
    
    /// Converts a `TrackStyle` into a concrete `ShapeStyle`,
    /// including support for angular gradients.
    ///
    /// - Parameters:
    ///   - style: The abstract track style to resolve.
    ///   - angles: The angular span used by the style.
    /// - Returns: A concrete shape style ready for drawing.
    func shapeStyle(_ style: TrackStyle, angles: (start: Angle, end: Angle)) -> AnyShapeStyle {
        switch style {
        case .solid(let color):
            return AnyShapeStyle(color)
            
        case .angularGradient(let colors, let center):
            return AnyShapeStyle(
                AngularGradient(
                    colors: colors,
                    center: center,
                    startAngle: angles.start,
                    endAngle: angles.end
                )
            )
        }
    }
    
    /// Visual style used for the base track.
    var baseShapeStyle: AnyShapeStyle {
        shapeStyle(tokens.track.style(for: .base), angles: trackAngles)
    }
    
    /// Visual style used for the active range arc.
    var rangeShapeStyle: AnyShapeStyle {
        shapeStyle(tokens.track.style(for: .range), angles: rangeAngles)
    }
}
