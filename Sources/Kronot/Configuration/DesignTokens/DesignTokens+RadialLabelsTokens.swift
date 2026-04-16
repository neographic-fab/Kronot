//
//  DesignTokens+RadialLabelsTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

public extension DesignTokens {
    /// Visual tokens for radial labels.
    ///
    /// `RadialLabelsTokens` defines the positioning and text styling used for
    /// labels arranged around the dial.
    struct RadialLabelsTokens {
        /// Distance between the radial labels and the major tick marks.
        public var inset: CGFloat = 16.0
        
        /// Text color used for radial labels.
        public var color: Color = .primary
        
        /// Font used for radial labels.
        public var font: Font = .subheadline
    }
}

extension DesignTokens.RadialLabelsTokens {
    /// Returns a sanitized copy of the radial label tokens.
    ///
    /// Applied rules:
    /// - `inset` is clamped to a non-negative value
    ///
    /// - Returns: A sanitized copy of `RadialLabelsTokens`, ready for rendering.
    func sanitized() -> Self {
        var copy = self
        copy.inset = max(.zero, copy.inset)
        return copy
    }
}
