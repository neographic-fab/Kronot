//
//  DesignTokens+ReadoutsTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Tokens for readout visuals.
///
/// Defines typography and color only; no formatting or interaction logic.
/// Intended to parameterize start/end/duration readouts.
public extension DesignTokens {
    struct ReadoutsTokens {
        /// Visual descriptor for a single readout.
        public struct Appearance {
            public var font: Font
            public var fontWeight: Font.Weight
            public var color: Color
        }

        /// Focus variants for a readout.
        public struct FocusState {
            public var idle: Appearance = .init(
                font: .title3,
                fontWeight: .semibold,
                color: .primary
            )
            public var focused: Appearance = .init(
                font: .title,
                fontWeight: .semibold,
                color: .primary
            )
        }

        public var start: FocusState = .init()
        public var end: FocusState = .init()
        public var duration: Appearance = .init(font: .subheadline, fontWeight: .regular, color: .secondary)
    }
}

// MARK: - Sanitization
extension DesignTokens.ReadoutsTokens {
    func sanitized() -> Self {
        self
    }
}
