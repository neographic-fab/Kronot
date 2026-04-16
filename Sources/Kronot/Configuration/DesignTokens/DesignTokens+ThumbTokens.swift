//
//  DesignTokens+ThumbTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Visual tokens for drag controls.
///
/// `ThumbTokens` defines the appearance of the start and end drag handles.
public extension DesignTokens {
    struct ThumbTokens {
        /// Visual appearance for a single drag handle.
        public struct Appearance {
            /// Relative scale factor based on the track width.
            public var scale: Scale = .large
            
            /// Whether a shadow is shown below the handle.
            public var showShadow: Bool = true
            
            /// Shadow color used by the handle.
            public var shadowColor: Color = .primary.opacity(0.2)
            
            /// Whether an icon is shown at the center of the handle.
            public var showIcon: Bool = true
            
            /// Icon color.
            public var iconColor: Color = .primary
            
            /// SF Symbols name used for the icon.
            public var iconSystemName: String = "clock.fill"
            
            /// Fill color of the handle.
            public var color: Color = .white

            /// Blur radius used for the handle shadow.
            internal var shadowRadius: CGFloat = 2.0
            
            /// Offset applied to the handle shadow.
            internal var shadowOffset: CGPoint = .init(x: .zero, y: 1)
        }

        /// Discrete scaling options for drag handles.
        public enum Scale {
            /// Preset scale values.
            case small, medium, large
            
            /// Custom scale factor relative to the track width.
            case factor(CGFloat)

            /// Numeric factor associated with the selected scale.
            var factor: CGFloat {
                switch self {
                case .small: 0.3
                case .medium: 0.5
                case .large: 0.8
                case .factor(let factor): factor
                }
            }
        }

        /// Appearance of the start handle.
        public var start: Appearance = .init()
        
        /// Appearance of the end handle.
        public var end: Appearance = .init()
    }
}

// MARK: - Sanitization
extension DesignTokens.ThumbTokens {
    /// Returns a sanitized copy of a single handle appearance.
    ///
    /// Applied rules:
    /// - if `scale` is `.factor`, the value is clamped to `0.1...1.5`
    /// - preset scale values are left unchanged
    private func sanitizedAppearance(_ appearance: Appearance) -> Appearance {
        var copy = appearance
        if case .factor(let factor) = copy.scale {
            copy.scale = .factor(factor.clamped(to: 0.1...1.5))
        }
        return copy
    }

    /// Returns a sanitized copy of the drag handle tokens.
    ///
    /// - Returns: A sanitized copy of `ThumbTokens`, ready for rendering.
    func sanitized() -> Self {
        var copy = self
        copy.start = copy.sanitizedAppearance(copy.start)
        copy.end = copy.sanitizedAppearance(copy.end)
        return copy
    }
}
