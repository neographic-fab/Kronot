//
//  RangeReference.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import Foundation

/// Reference to one of the two bounds of a time range.
///
/// `RangeReference` is used to distinguish between the start bound (`.start`)
/// and the end bound (`.end`).
enum RangeReference: CaseIterable {
    /// Start bound of the range.
    case start
    
    /// End bound of the range.
    case end
}

// MARK: - Derived Values
extension RangeReference {
    /// Localization key used as the accessibility label for the reference.
    var accessibilityLabelKey: LocalizedStringResource {
        switch self {
        case .start: return .accessibilityLabelStart
        case .end: return .accessibilityLabelEnd
        }
    }
    
    /// Returns the time value associated with this reference in the given range.
    ///
    /// - Parameter range: The range from which the value should be read.
    /// - Returns: The `TimeRange.Components` value corresponding to this reference.
    func value(in range: TimeRange) -> TimeRange.Components {
        switch self {
        case .start: return range.start
        case .end: return range.end
        }
    }
}
