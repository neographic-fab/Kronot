//
//  TrackMarker.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Draws marker ticks along the active segment of the track.
///
/// Marker ticks are placed using the granularity defined by
/// `parameters.behavior.snapMode`.
/// Color and stroke width are derived from `DesignTokens.track` and adapt
/// to increased contrast settings.
struct TrackMarker: View {
    let layout: RadialLayout
    let fractions: (RangeReference) -> Double
   
    @Environment(\.designTokens) private var tokens
    @Environment(\.parameters) private var parameters
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    /// Effective marker color, adjusted for increased contrast.
    private var effectiveColor: Color {
        if colorSchemeContrast == .increased {
            return .white
        }
        return tokens.track.markerColor
    }

    /// Effective marker stroke width, adjusted for increased contrast.
    private var effectiveLineWidth: CGFloat {
        let markerWidth = tokens.track.markerLineWidth
        if colorSchemeContrast == .increased {
            return markerWidth + 0.2
        }
        return markerWidth
    }

    var body: some View {
        Canvas { context, _ in
            context.translateBy(x: layout.center.x, y: layout.center.y)

            let radii = markerRadii()
            let activeRange = resolvedActiveRange(
                start: fractions(.start),
                end: fractions(.end),
                centerRadius: radii.center
            )

            guard let resolvedStart = activeRange.start,
                  let resolvedEnd = activeRange.end else { return }

            let totalTicks = TimeRange.minutesPerDay / parameters.behavior.snapMode.value

            for index in 0..<totalTicks {
                let fraction = Double(index) / Double(totalTicks)

                guard isInRange(fraction, start: resolvedStart, end: resolvedEnd) else { continue }

                drawMarker(
                    in: context,
                    angle: layout.angle(for: fraction),
                    innerRadius: radii.inner,
                    outerRadius: radii.outer
                )
            }
        }
        .accessibilityHidden(true)
    }
}

private extension TrackMarker {
    
    // MARK: - Geometry
    
    /// Computes the inner and outer radii used to draw marker ticks.
    func markerRadii() -> (inner: CGFloat, outer: CGFloat, center: CGFloat) {
        let centerRadius = layout.arcRadius(using: tokens)

        // Kept shorter than the full track width so markers read as ticks
        // rather than as a continuous band.
        let markerLength = tokens.track.lineWidth * tokens.track.markerLengthFactor
        let halfLength = markerLength * 0.5

        let innerRadius = centerRadius - halfLength
        let outerRadius = centerRadius + halfLength

        return (inner: innerRadius, outer: outerRadius, center: centerRadius)
    }
    
    /// Returns the effective diameter of a drag handle from the current token values.
    ///
    /// - Parameter thumb: The handle appearance to evaluate.
    /// - Returns: The clamped handle diameter.
    func thumbDiameter(for thumb: DesignTokens.ThumbTokens.Appearance) -> CGFloat {
        let rawSize = tokens.track.lineWidth * thumb.scale.factor
        return rawSize.clamped(to: 1...tokens.track.lineWidth)
    }
    
    /// Shrinks the active segment by leaving a small gap near both drag handles.
    ///
    /// This prevents markers from visually colliding with the start and end handles.
    ///
    /// - Parameters:
    ///   - start: Start fraction of the active segment.
    ///   - end: End fraction of the active segment.
    ///   - centerRadius: Radius used to estimate arc length.
    /// - Returns: A reduced active range, or `(nil, nil)` when the segment is too short.
    func resolvedActiveRange(start: Double, end: Double, centerRadius: CGFloat) -> (start: Double?, end: Double?) {
        let startThumbDiameter = thumbDiameter(for: tokens.thumb.start)
        let endThumbDiameter = thumbDiameter(for: tokens.thumb.end)
        let thumbRadius = max(startThumbDiameter, endThumbDiameter) * 0.5

        let thumbGap: CGFloat = 6
        let gapLength = thumbRadius + thumbGap

        let circumference = max(1, centerRadius * 2 * .pi)
        let gapFraction = Double(gapLength / circumference)

        let durationFraction = forwardFraction(from: start, to: end)
    
        guard durationFraction > gapFraction * 2 else { return (nil, nil) }

        return (
            start: (start + gapFraction).wrappedUnit,
            end: (end - gapFraction).wrappedUnit
        )
    }
    
    // MARK: - Drawing
    
    /// Draws a single marker tick at the specified angle.
    ///
    /// - Parameters:
    ///   - context: Graphics context used for drawing.
    ///   - angle: Angle at which the marker should be placed.
    ///   - innerRadius: Inner radius of the marker stroke.
    ///   - outerRadius: Outer radius of the marker stroke.
    func drawMarker(in context: GraphicsContext, angle: Angle, innerRadius: CGFloat, outerRadius: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: innerRadius, y: .zero))
        path.addLine(to: CGPoint(x: outerRadius, y: .zero))

        context.drawLayer { layer in
            layer.rotate(by: angle)
            layer.stroke(
                path,
                with: .color(effectiveColor),
                style: StrokeStyle(
                    lineWidth: effectiveLineWidth,
                    lineCap: .round
                )
            )
        }
    }
    
    // MARK: - Fraction Utilities
    
    /// Returns the forward distance between two wrapped unit fractions.
    ///
    /// - Parameters:
    ///   - start: Start fraction.
    ///   - end: End fraction.
    /// - Returns: The forward distance from `start` to `end`.
    func forwardFraction(from start: Double, to end: Double) -> Double {
        if start <= end {
            return end - start
        } else {
            return 1.0 - start + end
        }
    }
    
    /// Returns whether a fraction falls inside a wrapped forward range.
    ///
    /// - Parameters:
    ///   - value: Fraction to test.
    ///   - start: Start of the range.
    ///   - end: End of the range.
    /// - Returns: `true` when `value` is inside the wrapped range.
    func isInRange(_ value: Double, start: Double, end: Double) -> Bool {
        if start <= end {
            return value >= start && value <= end
        } else {
            return value >= start || value <= end
        }
    }
}
