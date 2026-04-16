//
//  DesignTokens+TickTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

public extension DesignTokens {
    /// Visual tokens for tick marks.
    ///
    /// `TickTokens` defines the appearance of major and minor tick marks,
    /// along with the inset applied to the tick ring.
    struct TickTokens {
        /// Visual appearance for a single tick mark.
        public struct Appearance {
            /// Length of the tick mark.
            public var length: CGFloat
            
            /// Stroke width of the tick mark.
            public var width: CGFloat
            
            /// Color of the tick mark.
            public var color: Color
        }

        /// Default appearance for major tick marks.
        public var major = Appearance(
            length: 12.0,
            width: 2.0,
            color: .primary
        )

        /// Default appearance for minor tick marks.
        public var minor = Appearance(
            length: 8.0,
            width: 1.0,
            color: .secondary
        )

        /// Inset applied to the tick ring relative to the track.
        public var inset: CGFloat = 4.0
    }
}

// MARK: - Sanitization
extension DesignTokens.TickTokens {
    /// Returns a sanitized copy of the tick tokens.
    ///
    /// Applied rules:
    /// - `inset` is clamped to a non-negative value
    /// - `length` and `width` for both major and minor ticks are clamped to non-negative values
    ///
    /// - Returns: A sanitized copy of `TickTokens`, ready for rendering.
    func sanitized() -> Self {
        var copy = self
        copy.inset = max(.zero, copy.inset)
        copy.major.length = max(.zero, copy.major.length)
        copy.major.width = max(.zero, copy.major.width)
        copy.minor.length = max(.zero, copy.minor.length)
        copy.minor.width = max(.zero, copy.minor.width)
        return copy
    }
}
