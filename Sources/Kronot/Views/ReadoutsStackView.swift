//
//  ReadoutsStackView.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Focus state used by the readout panels.
///
/// - `.idle`: shows the duration and hides start/end readouts at larger accessibility sizes
/// - `.focused(RangeReference)`: highlights the readout associated with the active reference
///
/// `ReadoutFocus` controls when start and end readouts are visible
/// and which one should appear emphasized.
enum ReadoutFocus: Equatable {
    case idle
    case focused(RangeReference)
    
    init(target: DragTarget) {
        switch target {
        case .reference(let reference): self = .focused(reference)
        case .idle, .range: self = .idle
        }
    }
}

/// Displays the start, duration, and end readout panels using styles derived from the current tokens.
///
/// - Parameters:
///   - focus: Focus state that determines which elements should be shown or emphasized.
///   - formatter: Formatter responsible for localized text output.
///   - range: The current time range.
///
/// Notes:
/// - visibility is adapted to the current `DynamicTypeSize`
/// - typography and colors are derived from `tokens.readouts`
struct ReadoutsStackView: View {
    let focus: ReadoutFocus
    let formatter: KronotFormatter
    let range: TimeRange
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.parameters) private var parameters
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @ScaledMetric(relativeTo: .title3) private var stackSpacing = 16.0
    @ScaledMetric(relativeTo: .footnote) private var timeStackSpacing = 12.0

    /// Composes the start, duration, and end readouts while applying focus
    /// and accessibility-driven visibility rules.
    var body: some View {
        VStack(spacing: stackSpacing) {
            content(for: .start)
            
            if focus == .idle {
                Text(formatter.durationText(for: range))
                    .font(tokens.readouts.duration.font)
                    .fontWeight(tokens.readouts.duration.fontWeight)
            }
            
            content(for: .end)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private typealias Appearance = DesignTokens.ReadoutsTokens.Appearance

private extension ReadoutsStackView {
    
    // MARK: - Readout Composition
    
    /// Builds the readout content for the specified reference,
    /// preserving the intended accessory and text order.
    ///
    /// - Parameter reference: The target reference, either `.start` or `.end`.
    @ViewBuilder
    func content(for reference: RangeReference) -> some View {
        if shouldShow(reference) {
            let resolvedRange = reference == .start ? range.start : range.end
            let text = formatter.timeText(for: resolvedRange)

            VStack(spacing: timeStackSpacing) {
                if reference == .start {
                    readoutsAccessoryView(for: .start)
                    Text(text).resolved(appearance(for: .start))
                } else {
                    Text(text).resolved(appearance(for: .end))
                    readoutsAccessoryView(for: .end)
                }
            }
        }
    }
    
    /// Builds the accessory view for the specified reference when one is configured.
    ///
    /// - Parameter reference: The target reference, either `.start` or `.end`.
    @ViewBuilder
    func readoutsAccessoryView(for reference: RangeReference) -> some View {
        let accessory = parameters.content.readout.accessory(for: reference)
        if accessory != nil {
            ReadoutsAccessoryView(reference: reference)
                .resolved(accessoryAppearance(for: reference))
        }
    }

    // MARK: - Visibility
    
    /// Returns whether the current Dynamic Type size is in an accessibility category.
    var isAccessible: Bool {
        dynamicTypeSize >= .accessibility1
    }

    /// Returns whether the readout associated with the specified reference should be shown.
    ///
    /// - Parameter reference: The target reference.
    /// - Returns: `true` when the readout should be visible.
    func shouldShow(_ reference: RangeReference) -> Bool {
        switch focus {
        case .focused(let ref): return ref == reference
        case .idle: return !isAccessible
        }
    }
    
    // MARK: - Resolved Appearance
        
    /// Returns the resolved text appearance for the specified readout,
    /// based on the current focus state.
    ///
    /// - Parameter reference: The target reference.
    /// - Returns: The appearance to apply to the readout text.
    func appearance(for reference: RangeReference) -> Appearance {
        let state: DesignTokens.ReadoutsTokens.FocusState =
            reference == .start ? tokens.readouts.start : tokens.readouts.end
        
        switch focus {
        case .focused(let ref):
            return ref == reference ? state.focused : state.idle
        case .idle:
            return state.idle
        }
    }
    
    /// Returns the resolved accessory appearance for the specified reference,
    /// based on the current focus state.
    ///
    /// - Parameter reference: The target reference.
    /// - Returns: The appearance to apply to the accessory view.
    func accessoryAppearance(for reference: RangeReference) -> Appearance {
        switch focus {
        case .focused(let ref):
            return ref == reference
                ? tokens.readouts.accessory.focused
                : tokens.readouts.accessory.idle
        case .idle:
            return tokens.readouts.accessory.idle
        }
    }
}

private extension View {
    /// Applies font, weight, and color using the provided `Appearance`.
    ///
    /// - Parameter appearance: The resolved visual appearance to apply.
    /// - Returns: A view styled using the given appearance.
    func resolved(_ appearance: Appearance) -> some View {
        self
            .font(appearance.font)
            .fontWeight(appearance.fontWeight)
            .foregroundStyle(appearance.color)
    }
}
