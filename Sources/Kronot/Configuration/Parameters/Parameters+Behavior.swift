//
//  Parameters+Behavior.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import Foundation

/// Behavioral parameters used by Kronot.
///
/// `Parameters.Behavior` groups the options that affect:
/// - the allowed active range, through `minActiveHours` and `maxActiveHours`
/// - the snapping granularity applied to time values, through `snapMode`
///
/// Use `sanitized()` to ensure values remain within valid domain constraints
/// before they are propagated through the app.
public extension Parameters {
    struct Behavior {
        /// Minimum allowed active range, expressed in hours.
        ///
        /// - Note: `sanitized()` clamps this value to the `1...23` range.
        public var minActiveHours: Int = 1
        
        /// Maximum allowed active range, expressed in hours.
        ///
        /// - Note: `sanitized()` clamps this value to the `1...23` range.
        public var maxActiveHours: Int = 20
        
        /// Snapping mode used to align minute values.
        public var snapMode: SnapMode = .everyQuarterHour
    }
}

// MARK: - SnapMode
public extension Parameters.Behavior {
    /// Snapping granularity for time values.
    ///
    /// Each case represents a time step expressed in minutes.
    /// Use `value` to retrieve the corresponding minute value.
    enum SnapMode {
        /// Snaps every 5 minutes.
        case everyFiveMinutes
        
        /// Snaps every 10 minutes.
        case everyTenMinutes
        
        /// Snaps every 15 minutes.
        case everyQuarterHour
        
        /// Snaps every 30 minutes.
        case everyHalfHour
        
        /// Snaps every 60 minutes.
        case everyHour
        
        /// Minute value associated with the snapping mode.
        var value: Int {
            switch self {
            case .everyFiveMinutes: return 5
            case .everyTenMinutes: return 10
            case .everyQuarterHour: return 15
            case .everyHalfHour: return 30
            case .everyHour: return 60
            }
        }
    }
}

// MARK: - Sanitization
public extension Parameters.Behavior {
    /// Returns a sanitized copy of the behavioral parameters.
    ///
    /// Applied rules:
    /// - `minActiveHours` and `maxActiveHours` are clamped to `1...23`
    /// - `minActiveHours` is adjusted so it does not exceed `maxActiveHours`
    ///
    /// - Returns: A sanitized copy of `Behavior` that satisfies the domain constraints.
    func sanitized() -> Self {
        var copy = self
        copy.minActiveHours = copy.minActiveHours.clamped(to: 1...23)
        copy.maxActiveHours = copy.maxActiveHours.clamped(to: 1...23)
        copy.minActiveHours = min(copy.minActiveHours, copy.maxActiveHours)
        return copy
    }
}
