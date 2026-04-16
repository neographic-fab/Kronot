//
//  Kronot+Output.swift
//  Kronot
//
//  Created by Fabio Floris on 16/04/2026.
//

import SwiftUI

/// Support extension for Kronot's formatted output.
///
/// Provides a UI-ready readout value with localized strings for start, end,
/// duration, and the combined range. The output is propagated using a
/// `PreferenceKey` so it can be read from views outside the control.

// MARK: - Output Model
public extension Kronot {
    /// Kronot output value intended to be displayed as a readout.
    ///
    /// Properties are strings already formatted and localized according to the
    /// current `Locale` and content settings. The type is `Sendable` and
    /// `Equatable` to simplify usage in bindings and state updates.
    struct Output: Sendable, Equatable {
        /// Formatted start time text (e.g. "10:00 PM").
        public let start: String
        /// Formatted end time text (e.g. "6:30 AM").
        public let end: String
        /// Formatted duration text (e.g. "8 h 30 min").
        public let duration: String
        /// Combined range text (e.g. "10:00 PM - 6:30 AM").
        public let range: String
    }
}

// MARK: - Output PreferenceKey
/// PreferenceKey used by `Kronot` to expose the formatted `Output`
/// outside of the control.
struct KronotOutputPreferenceKey: PreferenceKey {
    /// Default value: no output available.
    static let defaultValue: Kronot.Output? = nil
    
    /// Keeps the last non-nil value emitted in the hierarchy.
    /// When multiple children are present, the innermost value wins.
    // Use the next value if present, otherwise keep the current one.
    static func reduce(value: inout Kronot.Output?, nextValue: () -> Kronot.Output?) {
        value = nextValue() ??  value
    }
}

// MARK: - View API
/// Public API to read the `Output` from an external view.
public extension View {
    /// Binds a value that will receive `Kronot`'s formatted `Output`.
    ///
    /// Apply this modifier on the view containing `Kronot` to obtain already
    /// localized texts for start, end, and duration. The binding is updated
    /// reactively during interaction.
    ///
    /// - Parameter output: Binding that receives the current `Output` or `nil`
    ///   when no value is available.
    /// - Returns: The view configured to listen for preferences.
    ///
    /// Example:
    /// ```swift
    /// @State private var output: Kronot.Output?
    ///
    /// var body: some View {
    ///     Kronot(range: $range)
    ///         .kronotOutput($output)
    /// }
    /// ```
    func kronotOutput(_ output: Binding<Kronot.Output?>) -> some View {
        onPreferenceChange(KronotOutputPreferenceKey.self) { newValue in
            output.wrappedValue = newValue
        }
    }
}

