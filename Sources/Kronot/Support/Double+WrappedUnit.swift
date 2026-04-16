//
//  Double+WrappedUnit.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Foundation

extension Double {
    /// Wraps a unit fraction into the `0..<1` range.
    ///
    /// This is useful when a normalized fraction overflows or underflows
    /// the bounds of a single turn.
    ///
    /// Examples:
    /// - `1.2`  -> `0.2`
    /// - `-0.1` -> `0.9`
    var wrappedUnit: Self {
        let remainder = truncatingRemainder(dividingBy: 1)
        return remainder >= .zero ? remainder : remainder + 1
    }
}
