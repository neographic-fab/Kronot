//
//  Parameters.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Container for Kronot behavioral and content parameters.
///
/// `Parameters` is typically injected through `EnvironmentValues.parameters`.
/// Values are normalized through `sanitized()` to prevent invalid configurations.
public struct Parameters {
    /// Behavioral parameters such as snapping and active range constraints.
    public var behavior: Behavior = .init()
    
    /// Content parameters such as radial labels and readout configuration.
    public var content: Content = .init()
}

// MARK: - Sanitization
extension Parameters {
    /// Returns a sanitized copy of the parameter collection.
    ///
    /// `behavior` is currently normalized to enforce snapping and range constraints.
    /// `content` does not currently require sanitization, but remains part of this
    /// method for consistency and future extensibility.
    ///
    /// - Returns: A sanitized copy of `Parameters`, ready to be stored in the environment.
    func sanitized() -> Self {
        var copy = self
        copy.behavior = copy.behavior.sanitized()
        return copy
    }
}
