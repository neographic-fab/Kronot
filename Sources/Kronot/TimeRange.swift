//
//  TimeRange.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import SwiftUI

/// Represents a time range within a 24-hour day.
///
/// `TimeRange` stores a start and end value expressed as `Components`,
/// and provides derived values used by the radial control, including:
/// - normalized day fractions for the start and end references
/// - forward duration across midnight
/// - wrapping utilities for minute-based calculations
public struct TimeRange: Equatable {
    public var start: Components
    public var end: Components

    /// Creates a time range from explicit start and end components.
    ///
    /// - Parameters:
    ///   - start: Start time components.
    ///   - end: End time components.
    public init(start: Components, end: Components) {
        self.start = start
        self.end = end
    }
    
    /// Creates a range anchored to the current time with a discrete initial duration.
    ///
    /// - Parameter snapHours: Number of hours added to the current time to compute the end value.
    /// - Returns: A range whose `start` is set to the current time and whose `end`
    ///   is shifted forward by `snapHours`.
    public static func currentTime(snapHours: Int = 5) -> Self {
        let safeSnap = snapHours.clamped(to: 1...23)
        let now = Date()
        let start = Components(date: now)
        let end = Components(totalMinutes: start.minutesSinceMidnight + safeSnap * minutesPerHour)
        return Self(start: start, end: end)
    }
    
    /// Number of minutes in one hour.
    static let minutesPerHour = 60
    
    /// Number of hours in one day.
    static let hoursPerDay = 24
    
    /// Number of minutes in one day.
    static let minutesPerDay = hoursPerDay * minutesPerHour
    
    /// Forward duration from `start` to `end`, always expressed as a positive value.
    ///
    /// If `end` is earlier than `start`, the calculation wraps across midnight.
    ///
    /// Examples:
    /// - `08:00 -> 10:00 = 120`
    /// - `22:00 -> 01:00 = 180`
    var durationGoingForwardInMinutes: Int {
        Self.forwardDuration(from: start.minutesSinceMidnight, to: end.minutesSinceMidnight)
    }
    
    /// Fraction of the day corresponding to `start`, normalized to `0..<1`.
    var startFractionOfDay: Double {
        let startFraction = Double(start.minutesSinceMidnight) / Double(Self.minutesPerDay)
        return startFraction.wrappedUnit
    }
    
    /// Fraction of the day corresponding to `end`, normalized to `0..<1`.
    var endFractionOfDay: Double {
        let endFraction = Double(end.minutesSinceMidnight) / Double(Self.minutesPerDay)
        return endFraction.wrappedUnit
    }
}

// MARK: - Minute Utilities
extension TimeRange {
    /// Wraps a minute value into the valid range of a single day.
    ///
    /// - Parameter minutes: Minute value to normalize, including values outside the day range.
    /// - Returns: A wrapped value in the `0..<minutesPerDay` range.
    static func wrap(minutes: Int) -> Int {
        ((minutes % minutesPerDay) + minutesPerDay) % minutesPerDay
    }
    
    /// Returns the forward duration, in minutes, between two times of day.
    ///
    /// The calculation always moves forward and wraps across midnight when needed.
    ///
    /// Examples:
    /// - `08:00 -> 10:00 = 120`
    /// - `22:00 -> 01:00 = 180`
    ///
    /// - Parameters:
    ///   - start: Start minute value.
    ///   - end: End minute value.
    /// - Returns: The forward duration from `start` to `end`.
    static func forwardDuration(from start: Int, to end: Int) -> Int {
        let wrappedStart = wrap(minutes: start)
        let wrappedEnd = wrap(minutes: end)

        if wrappedEnd >= wrappedStart {
            return wrappedEnd - wrappedStart
        } else {
            return (minutesPerDay - wrappedStart) + wrappedEnd
        }
    }
    
    /// Returns the shortest wrapped delta between two minute values in a day.
    ///
    /// Examples:
    /// - `1435 -> 5 = 10`
    /// - `5 -> 1435 = -10`
    ///
    /// - Parameters:
    ///   - previous: Previous minute value.
    ///   - current: Current minute value.
    /// - Returns: The shortest signed delta between the two values.
    static func wrappedMinuteDelta(from previous: Int, to current: Int) -> Int {
        let day = minutesPerDay
        var delta = current - previous

        if delta > day / 2 {
            delta -= day
        } else if delta < -(day / 2) {
            delta += day
        }
        
        return delta
    }
}

// MARK: - Components
public extension TimeRange {
    /// Hour and minute value used by `TimeRange`.
    ///
    /// `Components` publicly exposes:
    /// - `hour`
    /// - `minute`
    ///
    /// It does not store `totalMinutes` directly.
    /// Minutes since midnight are derived as needed.
    struct Components: Equatable {
        public var hour: Int
        public var minute: Int

        /// Creates a value from explicit hour and minute components.
        ///
        /// Input values are normalized into a valid time of day.
        ///
        /// - Parameters:
        ///   - hour: Hour component.
        ///   - minute: Minute component.
        public init(hour: Int, minute: Int) {
            let totalMinutes = (hour * TimeRange.minutesPerHour) + minute
            self.init(totalMinutes: totalMinutes)
        }
        
        /// Creates a value from total minutes since midnight.
        ///
        /// This initializer remains internal to the package and is used by
        /// wrapping, snapping, gesture handling, and internal calculations.
        ///
        /// - Parameter totalMinutes: Total minutes since midnight, including out-of-range values.
        init(totalMinutes: Int) {
            let wrappedMinute = TimeRange.wrap(minutes: totalMinutes)
            self.hour = wrappedMinute / TimeRange.minutesPerHour
            self.minute = wrappedMinute % TimeRange.minutesPerHour
        }
        
        /// Creates a value by extracting hour and minute components from a `Date`.
        ///
        /// This initializer remains internal to the package and is used to create
        /// initial values from the current time.
        ///
        /// - Parameters:
        ///   - date: Source date.
        ///   - calendar: Calendar used to extract the time components.
        init(date: Date, using calendar: Calendar = .current) {
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            self.init(hour: hour, minute: minute)
        }
        
        /// Number of minutes elapsed since midnight.
        ///
        /// Examples:
        /// - `00:00 -> 0`
        /// - `01:30 -> 90`
        /// - `23:59 -> 1439`
        var minutesSinceMidnight: Int {
            hour * TimeRange.minutesPerHour + minute
        }
        
        /// Returns a new value shifted by the specified number of minutes.
        ///
        /// The result is always normalized into the valid range of a single day,
        /// which means it automatically supports:
        /// - forward wrapping past midnight
        /// - backward wrapping before `00:00`
        ///
        /// Examples:
        /// - `23:50 + 20` -> `00:10`
        /// - `00:10 - 20` -> `23:50`
        ///
        /// - Parameter minutes: Number of minutes to add. May be positive or negative.
        /// - Returns: A new `Components` value with the offset applied.
        func adding(minutes: Int) -> Self {
            .init(totalMinutes: minutesSinceMidnight + minutes)
        }
    }
}
