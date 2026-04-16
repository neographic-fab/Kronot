//
//  Kronot+Interaction.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Tiene lo stato temporaneo usato durante un drag attivo.
///
/// Questo stato conserva:
/// - il target coinvolto
/// - lo snapshot iniziale del range
/// - l'ultimo minuto toccato
/// - l'offset accumulato durante lo spostamento del range
struct DragState {
    var target: DragTarget = .idle
    var startMinutes: Int = .zero
    var endMinutes: Int = .zero
    var lastTouchMinute: Int = .zero
    var rangeOffsetMinutes: Int = .zero
}
/// Identifica quale parte del controllo è coinvolta durante il drag.
enum DragTarget {
    case idle
    case reference(RangeReference)
    case range
}

extension Kronot {
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
    /// Inizializza lo stato del drag a partire dalla posizione toccata.
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
    /// Aggiorna il controllo durante il drag in base al target attivo.
    func updateDrag( at location: CGPoint, in layout: RadialLayout) {
        let touchedMinute = touchedMinute(at: location, in: layout)
        switch dragState.target {
        case .idle: return
        case .reference(let reference):
            updateReference(reference, touchMinute: touchedMinute)
        case .range:
            updateRange(touchMinute: touchedMinute)
        }
    }
    /// Chiude il drag e ripristina lo stato temporaneo.
    func endDrag() {
        dragState = .init()
    }
}

private extension Kronot {
    /// Aggiorna uno dei due riferimenti del range rispettando:
    /// - lo snap configurato
    /// - la durata minima selezionabile
    /// - la durata massima selezionabile
    ///
    /// Il riferimento trascinato segue il dito.
    /// Quando la durata raggiunge i limiti, l'altro riferimento si adatta
    /// per mantenere il range entro i vincoli consentiti.
    func updateReference(_ reference: RangeReference, touchMinute: Int) {
        let candidateMinute = snappedMinute(for: touchMinute)
        let fixedMinute = fixedMinute(for: reference)
        let nextRange = resolvedRange(
            moving: reference,
            candidateMinute: candidateMinute,
            fixedMinute: fixedMinute
        )
        
        guard nextRange != range else { return }
        range = nextRange
        haptics.selectionChanged()
    }
    /// Sposta l'intero range mantenendo invariata la durata iniziale.
    func updateRange(touchMinute: Int) {
        let delta = dragDelta(to: touchMinute)
        
        dragState.rangeOffsetMinutes += delta
        dragState.lastTouchMinute = touchMinute
        
        let nextRange = shiftedRange(
            startMinute: dragState.startMinutes,
            endMinute: dragState.endMinutes,
            offset: dragState.rangeOffsetMinutes
        )
        
        guard nextRange != range else { return }
        range = nextRange
        haptics.selectionChanged()
    }
}

 extension Kronot {
    /// Restituisce il riferimento fisso mentre l'altro viene trascinato.
    func fixedMinute(for reference: RangeReference) -> Int {
        switch reference {
        case .start:
            return range.end.minutesSinceMidnight
        case .end:
            return range.start.minutesSinceMidnight
        }
    }
    /// Risolve il nuovo range finale partendo da:
    /// - il riferimento che si sta trascinando
    /// - il minuto candidato già snappato
    /// - il minuto fisso dell'altro estremo
    ///
    /// La durata viene sempre calcolata in forward e poi clampata
    /// ai limiti min/max configurati.
    func resolvedRange(moving reference: RangeReference, candidateMinute: Int, fixedMinute: Int) -> TimeRange {
        switch reference {
        case .start:
            let rawDuration = forwardDuration(from: candidateMinute, to: fixedMinute)
            let clampedDuration = clampedActiveDuration(rawDuration)
            let start = candidateMinute
            let end = wrappedMinutes(candidateMinute + clampedDuration)
            
            return .init(
                start: TimeRange.Components(totalMinutes: start),
                end: TimeRange.Components(totalMinutes: end)
            )
            
        case .end:
            let rawDuration = forwardDuration(from: fixedMinute, to: candidateMinute)
            let clampedDuration = clampedActiveDuration(rawDuration)
            let start = wrappedMinutes(candidateMinute - clampedDuration)
            let end = candidateMinute
            
            return .init(
                start: TimeRange.Components(totalMinutes: start),
                end: TimeRange.Components(totalMinutes: end)
            )
        }
    }
    /// Calcola il delta più corto tra l'ultimo minuto toccato e quello corrente,
    /// tenendo conto del wrap a mezzanotte.
    func dragDelta(to touchMinute: Int) -> Int {
        let lastTouchMinute = dragState.lastTouchMinute
        return wrappedMinuteDelta(from: lastTouchMinute, to: touchMinute)
    }
    /// Restituisce il range iniziale spostato dell'offset accumulato durante il drag.
    /// La durata resta invariata; cambiano solo posizione di start ed end.
    func shiftedRange(startMinute: Int, endMinute: Int, offset: Int) -> TimeRange {
        let shiftedStart = snappedMinute(for: wrappedMinutes(startMinute + offset))
        let shiftedEnd = snappedMinute(for: wrappedMinutes(endMinute + offset))
        
        return .init(
            start: TimeRange.Components(totalMinutes: shiftedStart),
            end: TimeRange.Components(totalMinutes: shiftedEnd)
        )
    }
}

private extension Kronot {
    /// Restituisce la durata forward da `start` a `end` sull'arco delle 24 ore.
    func forwardDuration(from start: Int, to end: Int) -> Int {
        let wrappedStart = wrappedMinutes(start)
        let wrappedEnd = wrappedMinutes(end)
        
        if wrappedEnd >= wrappedStart { return wrappedEnd - wrappedStart }
        else { return(TimeRange.minutesPerDay - wrappedStart) + wrappedEnd }
    }
    /// Applica i vincoli min/max alla durata attiva del range.
    func clampedActiveDuration(_ duration: Int) -> Int {
        let minMinutes = parameters.behavior.minActiveHours * TimeRange.minutesPerHour
        let maxMinutes = parameters.behavior.maxActiveHours * TimeRange.minutesPerHour
        return duration.clamped(to: minMinutes...maxMinutes)
    }
}

 extension Kronot {
    /// Applica lo snap configurato al minuto passato.
    func snappedMinute(for minute: Int) -> Int {
        let step = parameters.behavior.snapMode.value
        let wrapped = wrappedMinutes(minute)
        let snapped = Int(round(Double(wrapped) / Double(step))) * step
        return wrappedMinutes(snapped)
    }
    /// Riporta un valore di minuti nell'intervallo della giornata `0..<minutesPerDay`.
    func wrappedMinutes(_ minutes: Int) -> Int {
        let day = TimeRange.minutesPerDay
        let remainder = minutes % day
        return remainder >= .zero ? remainder : remainder + day
    }
    /// Restituisce il delta più corto tra due minuti della giornata,
    /// tenendo conto del wrap a mezzanotte.
    func wrappedMinuteDelta(from previous: Int, to current: Int) -> Int {
        let day = TimeRange.minutesPerDay
        var delta = current - previous
        
        if delta > day / 2 { delta -= day }
        else if delta < -(day / 2) { delta += day }
        return delta
    }
}

