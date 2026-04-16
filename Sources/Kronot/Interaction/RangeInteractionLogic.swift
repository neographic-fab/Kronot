//
//  RangeInteractionLogic.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Foundation

/// Pure interaction logic used to update a `TimeRange`.
///
/// `RangeInteractionLogic` is independent from SwiftUI and view state.
/// It receives simple inputs and produces deterministic outputs.
enum RangeInteractionLogic {
    
    // MARK: - Reference Resolution
    
    /// Returns the minute value of the reference that is not currently being dragged.
    ///
    /// - Parameters:
    ///   - reference: The reference being moved.
    ///   - range: The current range.
    /// - Returns: The minute value of the fixed reference.
    static func fixedMinute(for reference: RangeReference, in range: TimeRange) -> Int {
        switch reference {
        case .start: return range.end.minutesSinceMidnight
        case .end: return range.start.minutesSinceMidnight
        }
    }
    
    // MARK: - Snapping
    
    /// Aligns a minute value to the configured snapping granularity.
    ///
    /// The input value is first wrapped into the valid day range, then rounded
    /// to the nearest snapping step.
    ///
    /// - Parameters:
    ///   - minute: The minute value to align.
    ///   - mode: The snapping mode that defines the step size.
    /// - Returns: A wrapped and snapped minute value.
    static func snappedMinute(for minute: Int, mode: Parameters.Behavior.SnapMode) -> Int {
        let step = mode.value
        let wrapped = TimeRange.wrap(minutes: minute)
        let snapped = Int(round(Double(wrapped) / Double(step))) * step
        return TimeRange.wrap(minutes: snapped)
    }
    
    // MARK: - Duration Constraints
    
    /// Clamps an active duration to the minimum and maximum range allowed by `behavior`.
    ///
    /// - Parameters:
    ///   - duration: The candidate duration, expressed in minutes.
    ///   - behavior: The behavioral parameters that define the allowed bounds.
    /// - Returns: A clamped duration that satisfies the configured constraints.
    static func clampedActiveDuration(_ duration: Int, behavior: Parameters.Behavior) -> Int {
        let minMinutes = behavior.minActiveHours * TimeRange.minutesPerHour
        let maxMinutes = behavior.maxActiveHours * TimeRange.minutesPerHour
        return duration.clamped(to: minMinutes...maxMinutes)
    }
    
    // MARK: - Range Resolution
    
    /// Resolves the range produced by dragging one of the two references.
    ///
    /// The resulting range preserves forward duration semantics and applies
    /// the configured minimum and maximum duration constraints.
    ///
    /// - Parameters:
    ///   - reference: The reference being moved.
    ///   - candidateMinute: The snapped minute proposed for the dragged reference.
    ///   - fixedMinute: The minute value of the reference that remains fixed.
    ///   - behavior: The behavioral parameters used to clamp the resulting duration.
    /// - Returns: A new `TimeRange` consistent with the interaction rules.
    static func resolvedRange(
        moving reference: RangeReference,
        candidateMinute: Int,
        fixedMinute: Int,
        behavior: Parameters.Behavior
    ) -> TimeRange {
        switch reference {
        case .start:
            let rawDuration = TimeRange.forwardDuration(from: candidateMinute, to: fixedMinute)
            let clampedDuration = clampedActiveDuration(rawDuration, behavior: behavior)
            let start = TimeRange.wrap(minutes: candidateMinute)
            let end = TimeRange.wrap(minutes: candidateMinute + clampedDuration)

            return .init(
                start: TimeRange.Components(totalMinutes: start),
                end: TimeRange.Components(totalMinutes: end)
            )

        case .end:
            let rawDuration = TimeRange.forwardDuration(from: fixedMinute, to: candidateMinute)
            let clampedDuration = clampedActiveDuration(rawDuration, behavior: behavior)
            let start = TimeRange.wrap(minutes: candidateMinute - clampedDuration)
            let end = TimeRange.wrap(minutes: candidateMinute)

            return .init(
                start: TimeRange.Components(totalMinutes: start),
                end: TimeRange.Components(totalMinutes: end)
            )
        }
    }
    
    /// Shifts the entire range by a cumulative offset while preserving its duration.
    ///
    /// Both start and end are wrapped into the valid day range and snapped
    /// using the provided snapping mode.
    ///
    /// - Parameters:
    ///   - startMinute: The original start minute.
    ///   - endMinute: The original end minute.
    ///   - offset: The cumulative offset applied to both references.
    ///   - snapMode: The snapping mode applied after shifting.
    /// - Returns: A shifted `TimeRange`.
    static func shiftedRange(
        startMinute: Int,
        endMinute: Int,
        offset: Int,
        snapMode: Parameters.Behavior.SnapMode
    ) -> TimeRange {
        let shiftedStart = snappedMinute(
            for: TimeRange.wrap(minutes: startMinute + offset),
            mode: snapMode
        )

        let shiftedEnd = snappedMinute(
            for: TimeRange.wrap(minutes: endMinute + offset),
            mode: snapMode
        )

        return .init(
            start: TimeRange.Components(totalMinutes: shiftedStart),
            end: TimeRange.Components(totalMinutes: shiftedEnd)
        )
    }
}
