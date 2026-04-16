//
//  Kronot.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import SwiftUI

/// Interactive radial control for selecting a time range.
///
/// `Kronot` renders a 24-hour dial featuring:
/// - a base track
/// - an active arc representing the selected range
/// - two draggable handles for the start and end references
///
/// Interaction:
/// - drag the handles to adjust the start and end values
/// - drag the active arc to move the entire range
/// - full VoiceOver support through adjustable actions
///
/// Customization:
/// - visual styling through `DesignTokens`
/// - behavior and content configuration through `Parameters`
///
/// - Note: Tokens and parameters are read from the environment and sanitized automatically.
public struct Kronot: View {
    @Binding var range: TimeRange
    let haptics: KronotHaptics
    
    /// Creates a new `Kronot` control.
    ///
    /// - Parameter range: Binding to the time range displayed and edited by the control.
    ///   The binding is updated continuously during interaction.
    public init(range: Binding<TimeRange>) {
        self._range = range
        self.haptics = .init()
    }
    
    @Environment(\.locale) private var locale
    
    /// Behavioral and content parameters, including snapping, active range limits,
    /// labels, and readout accessories.
    @Environment(\.parameters) var parameters
    
    /// Visual design tokens used to style the track, ticks, handles,
    /// labels, and readouts.
    @Environment(\.designTokens) var tokens
    
    /// Internal interaction state used to drive focus, haptics,
    /// and range updates during drag gestures.
    @State var dragState: DragState = .init()
    
    /// Formatter used to localize and format radial labels and readout text.
    private var formatter: KronotFormatter  {
        KronotFormatter(
            locale: locale,
            showMeridiem: parameters.content.radialLabels.showMeridiem
        )
    }
    
    /// Composes the control using:
    /// - `TrackView` for the base track and active arc
    /// - `TickView` for decorative tick marks
    /// - `RadialLabelsView` for hour labels
    /// - `ReadoutsStackView` for start, duration, and end readouts
    /// - `ThumbView` for draggable start and end handles
    /// - an accessibility overlay for VoiceOver interaction
    public var body: some View {
        GeometryReader { proxy in
            let layout = RadialLayout(referenceSize: proxy.size)
            
            ZStack {
                TrackView(layout: layout, fractions: fraction(for:))
                TickView(layout: layout)
                RadialLabelsView(layout: layout, formatter: formatter)
                
                let focus: ReadoutFocus = .init(target: dragState.target)
                ReadoutsStackView(focus: focus, formatter: formatter, range: range)
                
                ForEach(RangeReference.allCases, id: \.self) { reference in
                    ThumbView(
                        reference: reference,
                        layout: layout,
                        fraction: fraction(for: reference)
                    )
                }
            }
            .contentShape(.circle)
            .gesture(dragGesture(in: layout))
            .frame(width: layout.side, height: layout.side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Publishes Kronot.Output via KronotOutputPreferenceKey for external consumers
            .preference(key: KronotOutputPreferenceKey.self, value: resolvedOutput)
            .overlay {
                ZStack {
                    ForEach(RangeReference.allCases, id: \.self) { reference in
                        accessibilityHandle(for: reference, in: layout)
                    }
                }
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Formatted Output Publication
private extension Kronot {
    /// Builds the formatted `Kronot.Output` for external readouts.
    ///
    /// - start: Localized time text for the range start.
    /// - end: Localized time text for the range end.
    /// - duration: Localized duration text for the forward interval.
    /// - range: Convenience combined text in the form "<start> - <end>".
    ///
    /// Values are produced using `KronotFormatter` with the current locale and
    /// content configuration.
    var resolvedOutput: Output {
        .init(start: formatter.timeText(for: range.start),
              end: formatter.timeText(for: range.end),
              duration: formatter.durationText(for: range),
              range: "\(formatter.timeText(for: range.start)) - \(formatter.timeText(for: range.end))")
    }
}

// MARK: - Derived Values
extension Kronot {
    /// Returns the fraction of the day associated with the specified reference.
    ///
    /// - Parameter reference: The target reference, either `.start` or `.end`.
    /// - Returns: A normalized fraction in the `0...1` range.
    func fraction(for reference: RangeReference) -> Double {
        switch reference {
        case .start: return range.startFractionOfDay
        case .end: return range.endFractionOfDay
        }
    }
}

// MARK: - Accessibility Elements
private extension Kronot {
    func accessibilityHandle(for reference: RangeReference, in layout: RadialLayout) -> some View {
        AccessibilityHandle(
            for: reference,
            in: layout,
            relativeTo: fraction(for: reference)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(reference.accessibilityLabelKey)
        .accessibilityValue(formatter.timeText(for: reference.value(in: range)))
        .accessibilitySortPriority(reference == .start ? 2 : 1)
        .accessibilityAdjustableAction { direction in
            adjust(reference, direction: direction)
        }
    }
}

// MARK: - Accessibility
private extension Kronot {
    /// Announces the updated value of the specified reference through VoiceOver.
    ///
    /// The announcement combines the localized accessibility label
    /// with the formatted time value.
    /// A small delay is used to avoid colliding with rapid UI updates.
    ///
    /// - Parameter reference: The reference whose value has changed.
    func announceTimeChange(for reference: RangeReference) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        
        let time = formatter.timeText(for: reference.value(in: range))
        let argument = "\(String(localized: reference.accessibilityLabelKey)), \(time)"
        
        UIAccessibility.post(notification: .announcement, argument: argument)
    }
    
    /// Converts an accessibility adjustment direction into a minute delta.
    ///
    /// - Parameters:
    ///   - direction: VoiceOver adjustment direction.
    ///   - step: Snap step expressed in minutes.
    /// - Returns: The corresponding delta, or `nil` for unsupported directions.
    func directionValue(_ direction: AccessibilityAdjustmentDirection, step: Int) -> Int? {
        switch direction {
        case .increment: return step
        case .decrement: return -step
        @unknown default: return nil
        }
    }
    
    /// Adjusts the specified reference in response to an accessibility action.
    ///
    /// The adjustment:
    /// - applies the configured snap step
    /// - respects the active range constraints
    /// - updates the bound range
    /// - emits haptic feedback
    /// - posts a VoiceOver announcement
    ///
    /// - Parameters:
    ///   - reference: The reference to adjust, either `.start` or `.end`.
    ///   - direction: Adjustment direction received from `accessibilityAdjustableAction`.
    func adjust(_ reference: RangeReference, direction: AccessibilityAdjustmentDirection) {
        let step = parameters.behavior.snapMode.value
        
        guard let delta = directionValue(direction, step: step) else { return }
        
        let current = reference.value(in: range).minutesSinceMidnight
        let candidate = RangeInteractionLogic.snappedMinute(
            for: current + delta,
            mode: parameters.behavior.snapMode
        )
        
        let fixed = RangeInteractionLogic.fixedMinute(for: reference, in: range)
        
        range = RangeInteractionLogic.resolvedRange(
            moving: reference,
            candidateMinute: candidate,
            fixedMinute: fixed,
            behavior: parameters.behavior
        )
        
        haptics.selectionChanged()
        announceTimeChange(for: reference)
    }
}

#Preview {
    @Previewable @State var range = TimeRange.currentTime()
    
    Kronot(range: $range)
        .designTokens { token in
            token.track.inset = 16
            token.tick.inset = 5
        }
        .parameters { param in
            param.behavior.snapMode = .everyQuarterHour
        }
}

