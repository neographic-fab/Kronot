//
//  Parameters+ViewModifier.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// A `ViewModifier` that reads the current `Parameters` from the environment,
/// applies a local configuration, and republishes the updated parameters.
///
/// How it works:
/// - reads the current parameters through `@Environment(\.parameters)`
/// - creates a mutable copy (`updated`) and applies the `configure` closure
/// - republishes the updated parameters with `environment(\.parameters, updated)`
/// - the environment setter automatically applies `sanitized()`
///
/// Benefits:
/// - changes remain local to this branch of the view hierarchy
/// - provides an ergonomic API through an `inout` configuration closure
///
/// Notes:
/// - modifier order matters: apply `.parameters` before customizations that depend on these values
/// - `sanitized()` is applied automatically when the value is assigned into the environment
private struct ParametersViewModifier: ViewModifier {
    @Environment(\.parameters) private var parameters
    let configure: (inout Parameters) -> Void
    
    /// Creates a mutable copy of the current parameters, applies the configuration,
    /// and republishes the updated value through the environment.
    func body(content: Content) -> some View {
        var updated = parameters
        configure(&updated)
        return content.environment(\.parameters, updated)
    }
}

public extension View {
    /// Applies a local `Parameters` configuration to this view and its descendants.
    ///
    /// - Parameter configure: A closure that receives a mutable copy of the current
    ///   parameters, allowing selected properties to be updated in place.
    ///
    /// - Returns: A view that republishes the updated parameters in the environment.
    ///
    /// Example:
    /// ```swift
    /// Kronot(...)
    ///     .parameters { params in
    ///         params.behavior.minActiveHours = 2
    ///         params.behavior.snapMode = .everyFiveMinutes
    ///     }
    /// ```
    ///
    /// Example of chaining and locality:
    /// ```swift
    /// HStack {
    ///     Kronot(...).parameters { $0.behavior.maxActiveHours = 12 }
    ///     Kronot(...).parameters { $0.behavior.maxActiveHours = 20 } // independent values
    /// }
    /// ```
    ///
    /// - Note: Sanitization is applied automatically when the value is assigned into the environment.
    func parameters(_ configure: @escaping (inout Parameters) -> Void) -> some View {
        modifier(ParametersViewModifier(configure: configure))
    }
}
