//
//  Kronot+Interaction.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Internal drag state used by `Kronot`.
///
/// `DragState` stores a snapshot of the current range and touch position,
/// allowing drag updates, offsets, and snapping to be computed consistently
/// during interaction.
struct DragState {
    var target: DragTarget = .idle
    var startMinutes: Int = .zero
    var endMinutes: Int = .zero
    var lastTouchMinute: Int = .zero
    var rangeOffsetMinutes: Int = .zero
}

/// Drag target used to distinguish between handle dragging
/// and full-range translation.
///
/// - `.idle`: no active interaction
/// - `.reference(RangeReference)`: dragging the start or end handle
/// - `.range`: dragging the active arc as a whole
enum DragTarget {
    case idle
    case reference(RangeReference)
    case range
}

extension Kronot {
    /// Main drag gesture used to handle drag start, updates, and completion.
    ///
    /// - Parameter layout: The radial layout used to convert touch locations into time values.
    /// - Returns: A gesture ready to be attached to the view.
    func dragGesture(in layout: RadialLayout) -> some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged { value in
                let location = value.location
                
                if case .idle = dragState.target {
                    beginDrag(at: location, in: layout)
                }
                
                updateDrag(at: location, in: layout)
            }
            .onEnded { _ in endDrag() }
    }
}

private extension Kronot {
    /// Begins a drag interaction by resolving the initial target
    /// and storing the starting interaction state.
    ///
    /// Haptics are prepared in advance to reduce feedback latency.
    func beginDrag(at location: CGPoint, in layout: RadialLayout) {
        let target = dragTarget(at: location, in: layout)
        let touchedMinute = touchedMinute(at: location, in: layout)

        dragState.target = target
        dragState.startMinutes = range.start.minutesSinceMidnight
        dragState.endMinutes = range.end.minutesSinceMidnight
        dragState.lastTouchMinute = touchedMinute
        dragState.rangeOffsetMinutes = .zero
        
        haptics.prepare()
    }
    
    /// Updates the current drag interaction by forwarding
    /// to the appropriate handler for the active target.
    func updateDrag(at location: CGPoint, in layout: RadialLayout) {
        let touchedMinute = touchedMinute(at: location, in: layout)
        
        switch dragState.target {
        case .idle:
            return
        case .reference(let reference):
            updateReference(reference, touchMinute: touchedMinute)
        case .range:
            updateRange(touchMinute: touchedMinute)
        }
    }
    
    /// Ends the current drag interaction and resets the internal drag state.
    func endDrag() {
        dragState = .init()
    }
}

private extension Kronot {
    /// Updates the dragged handle by applying snapping and range constraints.
    func updateReference(_ reference: RangeReference, touchMinute: Int) {
        let candidateMinute = RangeInteractionLogic.snappedMinute(
            for: touchMinute,
            mode: parameters.behavior.snapMode
        )

        let fixedMinute = RangeInteractionLogic.fixedMinute(for: reference, in: range)

        let nextRange = RangeInteractionLogic.resolvedRange(
            moving: reference,
            candidateMinute: candidateMinute,
            fixedMinute: fixedMinute,
            behavior: parameters.behavior
        )

        guard nextRange != range else { return }
        range = nextRange

        haptics.selectionChanged()
    }
    
    /// Moves the entire active range while preserving its original duration.
    func updateRange(touchMinute: Int) {
        let delta = dragDelta(to: touchMinute)

        dragState.rangeOffsetMinutes += delta
        dragState.lastTouchMinute = touchMinute

        let nextRange = RangeInteractionLogic.shiftedRange(
            startMinute: dragState.startMinutes,
            endMinute: dragState.endMinutes,
            offset: dragState.rangeOffsetMinutes,
            snapMode: parameters.behavior.snapMode
        )

        guard nextRange != range else { return }
        range = nextRange

        haptics.selectionChanged()
    }
}

extension Kronot {
    /// Returns the shortest wrapped delta between the previous touch minute
    /// and the current touch minute.
    func dragDelta(to touchMinute: Int) -> Int {
        let lastTouchMinute = dragState.lastTouchMinute
        return TimeRange.wrappedMinuteDelta(from: lastTouchMinute, to: touchMinute)
    }
}
