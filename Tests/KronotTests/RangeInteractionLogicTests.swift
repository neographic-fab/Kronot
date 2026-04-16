//
//  RangeInteractionLogicTests.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Testing
@testable import Kronot

@Suite("RangeInteractionLogic: snap, vincoli e risoluzione range")
struct RangeInteractionLogicTests {
    @Test("snappedMinute: arrotonda al quarto d'ora più vicino")
    func snappedMinute_roundsToNearestQuarterHour() {
        // When
        let snapped = RangeInteractionLogic.snappedMinute(for: 68, mode: .everyQuarterHour)
        // Then: 68 → 75
        #expect(snapped == 75)
    }

    @Test("snappedMinute: wrap a fine giornata")
    func snappedMinute_wrapsAtEndOfDay() {
        // When: 1438 minuti (~23:58), snap a quarto d'ora
        let snapped = RangeInteractionLogic.snappedMinute(for: 1438, mode: .everyQuarterHour)
        // Then: wrap a 00:00
        #expect(snapped == 0)
    }

    @Test("fixedMinute(.start): restituisce end del range")
    func fixedMinute_forStart_returnsRangeEnd() {
        // Given
        let range = TimeRange(start: .init(hour: 8, minute: 0), end: .init(hour: 10, minute: 0))
        // When
        let fixed = RangeInteractionLogic.fixedMinute(for: .start, in: range)
        // Then: 10:00 → 600
        #expect(fixed == 600)
    }

    @Test("fixedMinute(.end): restituisce start del range")
    func fixedMinute_forEnd_returnsRangeStart() {
        // Given
        let range = TimeRange(start: .init(hour: 8, minute: 0), end: .init(hour: 10, minute: 0))
        // When
        let fixed = RangeInteractionLogic.fixedMinute(for: .end, in: range)
        // Then: 08:00 → 480
        #expect(fixed == 480)
    }

    @Test("clampedActiveDuration: rispetta ore minime")
    func clampedActiveDuration_respectsMinimumHours() {
        // Given
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = 2
        behavior.maxActiveHours = 20
        // When: durata proposta 30 minuti < 2h
        let clamped = RangeInteractionLogic.clampedActiveDuration(30, behavior: behavior)
        // Then: clamp a 120 minuti
        #expect(clamped == 120)
    }

    @Test("clampedActiveDuration: rispetta ore massime")
    func clampedActiveDuration_respectsMaximumHours() {
        // Given
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = 1
        behavior.maxActiveHours = 3
        // When: durata proposta 8h > 3h
        let clamped = RangeInteractionLogic.clampedActiveDuration(8 * 60, behavior: behavior)
        // Then: clamp a 180 minuti
        #expect(clamped == 180)
    }

    @Test("resolvedRange(moving: .start): rispetta durata minima")
    func resolvedRange_movingStart_respectsMinimumDuration() {
        // Given
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = 2
        behavior.maxActiveHours = 20
        // When
        let range = RangeInteractionLogic.resolvedRange(
            moving: .start,
            candidateMinute: 9 * 60,
            fixedMinute: 10 * 60,
            behavior: behavior
        )
        // Then: 09:00 → 11:00
        #expect(range.start.hour == 9)
        #expect(range.start.minute == 0)
        #expect(range.end.hour == 11)
        #expect(range.end.minute == 0)
    }

    @Test("resolvedRange(moving: .end): rispetta durata massima")
    func resolvedRange_movingEnd_respectsMaximumDuration() {
        // Given
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = 1
        behavior.maxActiveHours = 3
        // When
        let range = RangeInteractionLogic.resolvedRange(
            moving: .end,
            candidateMinute: 15 * 60,
            fixedMinute: 8 * 60,
            behavior: behavior
        )
        // Then: 12:00 → 15:00
        #expect(range.start.hour == 12)
        #expect(range.start.minute == 0)
        #expect(range.end.hour == 15)
        #expect(range.end.minute == 0)
    }

    @Test("shiftedRange: applica offset e snap")
    func shiftedRange_appliesOffsetAndSnap() {
        // When: offset 17 minuti, snap a quarto d'ora
        let shifted = RangeInteractionLogic.shiftedRange(
            startMinute: 8 * 60,
            endMinute: 10 * 60,
            offset: 17,
            snapMode: .everyQuarterHour
        )
        // Then: 08:15 → 10:15
        #expect(shifted.start.hour == 8)
        #expect(shifted.start.minute == 15)
        #expect(shifted.end.hour == 10)
        #expect(shifted.end.minute == 15)
    }

    @Test("shiftedRange: wrap attraverso mezzanotte")
    func shiftedRange_wrapsAcrossMidnight() {
        // When: offset 30 minuti, wrap 23:45→00:15 e 01:45→02:15
        let shifted = RangeInteractionLogic.shiftedRange(
            startMinute: 23 * 60 + 45,
            endMinute: 1 * 60 + 45,
            offset: 30,
            snapMode: .everyQuarterHour
        )
        // Then: 00:15 → 02:15
        #expect(shifted.start.hour == 0)
        #expect(shifted.start.minute == 15)
        #expect(shifted.end.hour == 2)
        #expect(shifted.end.minute == 15)
    }
}
