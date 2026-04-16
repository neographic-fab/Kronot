//
//  Environment+Parameters.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Environment key implementation for `Parameters`.
///
/// This key provides a default value and centralizes access to the
/// shared behavioral parameters stored in the environment.
private struct ParametersEnvironmentKey: EnvironmentKey {
    static var defaultValue: Parameters { .init() }
}

extension EnvironmentValues {
    /// The shared behavioral parameters stored in the environment.
    ///
    /// - Getter: Reads the current parameters from the environment, or the default value when none has been provided.
    /// - Setter: Applies `sanitized()` before propagating the value, preventing invalid configurations from being stored.
    ///
    /// Examples:
    /// ```swift
    /// @Environment(\.parameters) var parameters
    /// content.environment(\.parameters, updatedParameters)
    /// ```
    ///
    /// - Note: Sanitization is applied automatically on assignment.
    var parameters: Parameters {
        get { self[ParametersEnvironmentKey.self] }
        set { self[ParametersEnvironmentKey.self] = newValue.sanitized() }
    }
}
