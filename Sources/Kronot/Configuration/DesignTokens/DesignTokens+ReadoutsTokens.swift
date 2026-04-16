//
//  DesignTokens+ReadoutsTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

public extension DesignTokens {
    /// Visual tokens for readout panels.
    ///
    /// `ReadoutsTokens` defines the typography and color used by the readout area.
    /// It does not include formatting or interaction logic.
    ///
    /// These tokens style the readouts for:
    /// - the start time
    /// - the end time
    /// - the overall duration
    /// - accessory labels associated with the active selection
    struct ReadoutsTokens {
        /// Visual appearance for a single readout.
        public struct Appearance {
            /// Font used for the text.
            public var font: Font
            
            /// Font weight used for the text.
            public var fontWeight: Font.Weight
            
            /// Text color.
            public var color: Color
        }

        /// Visual variants for focused and unfocused states.
        public struct FocusState {
            /// Appearance used when the readout is not focused.
            public var idle: Appearance = .init(
                font: .title3,
                fontWeight: .semibold,
                color: .primary
            )
            
            /// Appearance used when the readout is focused.
            public var focused: Appearance = .init(
                font: .title,
                fontWeight: .semibold,
                color: .primary
            )
        }

        /// Visual configuration for the start readout.
        public var start: FocusState = .init()
        
        /// Visual configuration for the end readout.
        public var end: FocusState = .init()
        
        /// Visual configuration for the overall duration readout.
        public var duration: Appearance = .init(
            font: .subheadline,
            fontWeight: .regular,
            color: .secondary
        )
        
        /// Visual configuration for accessory labels associated with the active readout.
        public var accessory: FocusState = .init(
            idle: .init(font: .footnote, fontWeight: .regular, color: .primary),
            focused: .init(font: .footnote, fontWeight: .semibold, color: .primary)
        )
    }
}
