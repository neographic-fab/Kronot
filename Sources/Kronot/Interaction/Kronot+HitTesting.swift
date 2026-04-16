//
//  Kronot+HitTesting.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

// MARK: - Radial Hit Testing
extension Kronot {
    /// Converts a touch location into minutes since midnight.
    ///
    /// Returns the corresponding minute of the day for the touched position.
    /// The result is normalized to the `0..<minutesPerDay` range.
    ///
    /// - Parameters:
    ///   - location: The touched point.
    ///   - layout: The reference radial layout.
    /// - Returns: A normalized minute of the day.
    func touchedMinute(at location: CGPoint, in layout: RadialLayout) -> Int {
        let fraction = touchedFraction(at: location, in: layout)
        let totalMinutes = Int(round(fraction * Double(TimeRange.minutesPerDay)))
        return totalMinutes % TimeRange.minutesPerDay
    }
    
    /// Returns the nearest start or end reference for the touched location,
    /// when it falls within the hit radius.
    ///
    /// - Parameters:
    ///   - location: The touched point.
    ///   - layout: The reference radial layout.
    /// - Returns: The nearest reference, or `nil` if the touch is outside the hit radius.
    func nearestReference(to location: CGPoint, in layout: RadialLayout) -> RangeReference? {
        let startDistance = distance(from: location, to: thumbCenter(for: .start, in: layout))
        let endDistance = distance(from: location, to: thumbCenter(for: .end, in: layout))

        guard min(startDistance, endDistance) <= thumbHitRadius else {
            return nil
        }

        return startDistance <= endDistance ? .start : .end
    }
    
    /// Determines the initial drag target for a touch location.
    ///
    /// Priority order:
    /// 1. start or end handle
    /// 2. active arc
    /// 3. no target
    ///
    /// - Parameters:
    ///   - location: The touched point.
    ///   - layout: The reference radial layout.
    /// - Returns: The selected drag target.
    func dragTarget(at location: CGPoint, in layout: RadialLayout) -> DragTarget {
        if let reference = nearestReference(to: location, in: layout) {
            return .reference(reference)
        }
        
        if isPointNearActiveArc(location, in: layout) {
            return .range
        }
        
        return .idle
    }
}

private extension Kronot {
    /// Minimum hit radius used to detect drag handles,
    /// adjusted to the current track width.
    var thumbHitRadius: CGFloat { max(22, tokens.track.lineWidth) }
    
    /// Radial tolerance used to consider a touch as being near the active arc.
    var activeArcRingTolerance: CGFloat { max(18, tokens.track.lineWidth) }
    
    /// Normalized dial fraction corresponding to the touched point.
    func touchedFraction(at location: CGPoint, in layout: RadialLayout) -> Double {
        let normalizedAngle = normalizedTouchAngle(at: location, in: layout)
        return (normalizedAngle / 360.0).wrappedUnit
    }
    
    /// Touch angle normalized relative to the dial's zero position.
    func normalizedTouchAngle(at location: CGPoint, in layout: RadialLayout) -> Double {
        let dx = location.x - layout.center.x
        let dy = location.y - layout.center.y
        var angle = atan2(dy, dx) * 180.0 / .pi

        angle -= layout.zeroAngle.degrees

        while angle < .zero {
            angle += 360.0
        }

        return angle
    }
    
    /// Geometric center of the handle associated with the specified reference.
    func thumbCenter(for reference: RangeReference, in layout: RadialLayout) -> CGPoint {
        let referenceFraction = fraction(for: reference)
        let referenceAngle = layout.angle(for: referenceFraction)
        let thumbRadius = layout.thumbRadius(using: tokens)

        return CGPoint(
            x: layout.center.x + cos(referenceAngle.radians) * thumbRadius,
            y: layout.center.y + sin(referenceAngle.radians) * thumbRadius
        )
    }
    
    /// Returns whether the touched point is both near the arc ring
    /// and inside the active arc segment.
    func isPointNearActiveArc(_ location: CGPoint, in layout: RadialLayout) -> Bool {
        let isNearRing = isPointNearArcRing(location, in: layout)
        guard isNearRing else { return false }

        let fraction = touchedFraction(at: location, in: layout)
        return isFractionOnActiveArc(fraction, in: layout)
    }
    
    /// Returns whether the touched point is close enough to the track circumference,
    /// using the configured radial tolerance.
    func isPointNearArcRing(_ location: CGPoint, in layout: RadialLayout) -> Bool {
        let distanceFromCenter = distance(from: location, to: layout.center)
        let arcRadius = layout.arcRadius(using: tokens)

        return abs(distanceFromCenter - arcRadius) <= activeArcRingTolerance
    }
    
    /// Returns whether the touched fraction falls inside the active arc range,
    /// including a small tolerance on both ends.
    func isFractionOnActiveArc(_ touchedFraction: Double, in layout: RadialLayout) -> Bool {
        let startFraction = fraction(for: .start)
        let endFraction = fraction(for: .end)
        let tolerance = activeArcFractionTolerance(in: layout)
        
        let expandedStart = (startFraction - tolerance).wrappedUnit
        let expandedEnd = (endFraction + tolerance).wrappedUnit
        
        return isInRange(
            touchedFraction,
            start: expandedStart,
            end: expandedEnd
        )
    }
    
    /// Tolerance, expressed as a fraction of the full day,
    /// used when hit testing the active arc.
    func activeArcFractionTolerance(in layout: RadialLayout) -> Double {
        let radius = layout.arcRadius(using: tokens)
        guard radius > .zero else { return .zero }

        let arcLengthTolerance = max(12.0, Double(tokens.track.lineWidth) * 0.5)
        return arcLengthTolerance / (2.0 * .pi * Double(radius))
    }
    
    /// Euclidean distance between two points.
    func distance(from point: CGPoint, to otherPoint: CGPoint) -> CGFloat {
        hypot(point.x - otherPoint.x, point.y - otherPoint.y)
    }
    
    /// Forward distance between two unit fractions, handling wrap-around at `1.0`.
    func forwardFraction(from start: Double, to end: Double) -> Double {
        if start <= end {
            return end - start
        } else {
            return 1.0 - start + end
        }
    }
    
    /// Returns whether a unit value falls inside a range that may wrap around `1.0`.
    func isInRange(_ value: Double, start: Double, end: Double) -> Bool {
        if start <= end {
            return value >= start && value <= end
        } else {
            return value >= start || value <= end
        }
    }
}
