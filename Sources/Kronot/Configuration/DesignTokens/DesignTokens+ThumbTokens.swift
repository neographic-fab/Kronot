//
//  DesignTokens+ThumbTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Tokens for thumb visuals.
///
/// Defines appearance only; no layout, gesture, or hit-testing logic.
/// Intended to parameterize the look of start/end thumbs.
public extension DesignTokens {
    struct ThumbTokens {
        /// Visual descriptor for a single thumb.
        public struct Appearance {
            /// Relative scale against track line width.
            public var scale: Scale = .large
            public var showShadow: Bool = true
            public var shadowColor: Color = .primary.opacity(0.2)
            public var showIcon: Bool = true
            public var iconColor: Color = .primary
            public var iconSystemName: String = "clock.fill"
            public var color: Color = .white

            internal var shadowRadius: CGFloat = 2.0
            internal var shadowOffset: CGPoint = .init(x: .zero, y: 1)
        }

        /// Discrete scale options for thumbs.
        public enum Scale {
            case small, medium, large
            case factor(CGFloat)

            var factor: CGFloat {
                switch self {
                case .small: 0.3
                case .medium: 0.5
                case .large: 0.8
                case .factor(let factor): factor
                }
            }
        }

        /// Start thumb appearance.
        public var start: Appearance = .init()
        /// End thumb appearance.
        public var end: Appearance = .init()
    }
}

// MARK: - Sanitization
extension DesignTokens.ThumbTokens {
    private func sanitizedAppearance(_ appearance: Appearance) -> Appearance {
        var copy = appearance
        if case .factor(let factor) = copy.scale {
            copy.scale = .factor(factor.clamped(to: 0.1...1.5))
        }
        return copy
    }

    func sanitized() -> Self {
        var copy = self
        copy.start = copy.sanitizedAppearance(copy.start)
        copy.end = copy.sanitizedAppearance(copy.end)
        return copy
    }
}
