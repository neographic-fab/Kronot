//
//  DesignTokens+ViewModifier.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// A `ViewModifier` that reads the current `DesignTokens` from the environment,
/// applies a local configuration, and republishes the updated tokens.
///
/// How it works:
/// - reads the current tokens through `@Environment(\.designTokens)`
/// - creates a mutable copy (`updated`) and applies the `configure` closure
/// - republishes the updated tokens with `environment(\.designTokens, updated)`
/// - the environment setter automatically applies `sanitized()`
///
/// Benefits:
/// - changes remain local to this branch of the view hierarchy
/// - global tokens are never mutated directly
///
/// Notes:
/// - modifier order matters: apply `.designTokens` before other customizations that depend on these values
/// - `sanitized()` is applied automatically by the environment setter
private struct DesignTokensViewModifier: ViewModifier {
    @Environment(\.designTokens) private var tokens
    let configure: (inout DesignTokens) -> Void
    
    func body(content: Content) -> some View {
        var updated = tokens
        configure(&updated)
        return content.environment(\.designTokens, updated)
    }
}

public extension View {
    /// Applies a local `DesignTokens` configuration to this view and its descendants.
    ///
    /// - Parameter configure: A closure that receives a mutable copy of the current
    ///   design tokens, allowing selected fields to be updated in place.
    ///
    /// - Returns: A view that republishes the updated design tokens in the environment.
    ///
    /// Example:
    /// ```swift
    /// Kronot(...)
    ///     .designTokens { tokens in
    ///         tokens.tick.inset = 5
    ///         tokens.track.setStyle(.angular(.green, .yellow), for: .range)
    ///     }
    /// ```
    ///
    /// Example of chaining and locality:
    /// ```swift
    /// VStack {
    ///     Kronot(...)
    ///         .designTokens { $0.tick.inset = 4 }
    ///     Kronot(...)
    ///         .designTokens { $0.tick.inset = 12 } // does not affect the previous one
    /// }
    /// ```
    ///
    /// Changes remain local to the modified branch and do not affect other parts of the interface.
    func designTokens(_ configure: @escaping (inout DesignTokens) -> Void) -> some View {
        modifier(DesignTokensViewModifier(configure: configure))
    }
}
