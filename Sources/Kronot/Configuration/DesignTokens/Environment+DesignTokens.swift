//
//  Environment+DesignTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Environment key implementation for `DesignTokens`.
///
/// This key provides a safe default value and centralizes access to the
/// shared design tokens stored in the environment.
private struct DesignTokensEnvironmentKey: EnvironmentKey {
    static var defaultValue: DesignTokens { .init() }
}

extension EnvironmentValues {
    /// The shared design tokens stored in the environment.
    ///
    /// - Getter: Reads the current tokens from the environment, or the default value when none has been provided.
    /// - Setter: Applies `sanitized()` before propagating the value, preventing invalid configurations from being stored.
    ///
    /// Examples:
    /// ```swift
    /// @Environment(\.designTokens) var tokens
    /// content.environment(\.designTokens, updatedTokens)
    /// ```
    ///
    /// - Note: Sanitization is applied automatically on assignment.
    var designTokens: DesignTokens {
        // Sanitizes the tokens before storing them in the environment.
        set { self[DesignTokensEnvironmentKey.self] = newValue.sanitized() }
        get { self[DesignTokensEnvironmentKey.self] }
    }
}
