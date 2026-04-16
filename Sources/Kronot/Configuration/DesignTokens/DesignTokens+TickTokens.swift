//
//  DesignTokens+TickTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Tokens for tick visuals.
///
/// Defines appearance only; no layout or positioning logic.
/// Intended to style major/minor tick marks.
public extension DesignTokens {
    struct TickTokens {
        /// Visual descriptor for a single tick mark.
        public struct Appearance {
            public var length: CGFloat
            public var width: CGFloat
            public var color: Color
        }

        public var major = Appearance(
            length: 12.0,
            width: 2.0,
            color: .primary
        )

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
