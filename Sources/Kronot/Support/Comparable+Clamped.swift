//
//  Comparable+Clamped.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import SwiftUI

/// Convenience utilities for `Comparable` types.
///
/// This extension provides common helpers such as clamping a value
/// to a closed range.
extension Comparable {
    /// Returns the value clamped to the specified range.
    ///
    /// - Parameter range: The target closed range.
    /// - Returns: `self` if it already falls inside `range`, otherwise the nearest bound.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
