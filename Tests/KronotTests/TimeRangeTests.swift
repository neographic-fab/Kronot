//
//  TimeRangeTests.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Testing
@testable import Kronot

@Suite("TimeRange: Durata e frazioni del giorno")
struct TimeRangeDurationAndFractionsTests {
    @Test("Durata stesso giorno")
    func duration_sameDay() {
        // Given: un range 08:00 → 10:30 nello stesso giorno
        let range = TimeRange(
            start: .init(hour: 8, minute: 0),
            end: .init(hour: 10, minute: 30)
        )
        // Then
        #expect(range.durationGoingForwardInMinutes == 150)
    }

    @Test("Durata attraversando la mezzanotte")
    func duration_wrapAroundMidnight() {
        // Given: un range 22:00 → 01:00 che attraversa la mezzanotte
        let range = TimeRange(
            start: .init(hour: 22, minute: 0),
            end: .init(hour: 1, minute: 0)
        )
        // Then
        #expect(range.durationGoingForwardInMinutes == 180)
    }

    @Test("Frazione start a mezzogiorno è metà giornata")
    func startFraction_midday_isHalfDay() {
        let range = TimeRange(
            start: .init(hour: 12, minute: 0),
            end: .init(hour: 18, minute: 0)
        )
        #expect(range.startFractionOfDay == 0.5)
    }

    @Test("Frazione end a un quarto di giornata")
    func endFraction_quarterDay_isCorrect() {
        let range = TimeRange(
            start: .init(hour: 0, minute: 0),
            end: .init(hour: 6, minute: 0)
        )
        #expect(range.endFractionOfDay == 0.25)
    }
}

@Suite("TimeRange: Components e wrapping minuti")
struct TimeRangeComponentsWrappingTests {
    @Test("adding(minutes:) oltre la mezzanotte")
    func componentsAdding_wrapsForwardOverMidnight() {
        // Given
        let start = TimeRange.Components(hour: 23, minute: 50)
        // When: aggiungo 20 minuti → attraversa la mezzanotte
        let shifted = start.adding(minutes: 20)
        // Then: 00:10
        #expect(shifted.hour == 0)
        #expect(shifted.minute == 10)
    }

    @Test("adding(minutes:) prima di mezzanotte")
    func componentAdding_wrapsBackwardBeforeMidnight() {
        // Given
        let start = TimeRange.Components(hour: 0, minute: 10)
        // When: sottraggo 20 minuti → va al giorno precedente
        let shifted = start.adding(minutes: -20)
        // Then: 23:50
        #expect(shifted.hour == 23)
        #expect(shifted.minute == 50)
    }

    @Test("wrap normalizza valori negativi")
    func wrap_minutes_normalizesNegativeValues() {
        // -10 minuti equivalgono a 23:50 → 1430
        #expect(TimeRange.wrap(minutes: -10) == 1430)
    }

    @Test("wrap normalizza valori oltre la durata del giorno")
    func wrap_minutes_normalizesValuesBeyondDayLength() {
        // 1450 minuti ≡ 24:10 → 00:10 → 10
        #expect(TimeRange.wrap(minutes: 1450) == 10)
    }
}

@Suite("TimeRange: Utility di calcolo (forward e delta)")
struct TimeRangeUtilitiesTests {
    @Test("Durata forward attraversando mezzanotte")
    func forwardDuration_acrossMidnight_isCorrect() {
        // 23:00 → 01:00 = 120 minuti
        let duration = TimeRange.forwardDuration(
            from: 23 * 60,
            to: 1 * 60
        )
        #expect(duration == 120)
    }

    @Test("Delta fra minuti: percorso più breve forward")
    func wrappedMinuteDelta_acrossMidnight_forwardIsShortestPath() {
        // Il percorso più breve tra 23:55 (1435) e 00:05 (5) è +10 minuti
        let delta = TimeRange.wrappedMinuteDelta(from: 1435, to: 5)
        #expect(delta == 10)
    }

    @Test("Delta fra minuti: percorso più breve backward")
    func wrappedMinuteDelta_acrossMidnight_backwardIsShortestPath() {
        // Il percorso più breve tra 00:05 (5) e 23:55 (1435) è -10 minuti
        let delta = TimeRange.wrappedMinuteDelta(from: 5, to: 1435)
        #expect(delta == -10)
    }

    @Test("currentTime: clamp delle ore di snap nel range valido")
    func currentTime_clampSnapHoursToValidRange() {
        // Given: chiedo una durata iniziale non valida (99 ore)
        let range = TimeRange.currentTime(snapHours: 99)
        // Then: la durata viene clampata a 23 ore (range massimo)
        let duration = range.durationGoingForwardInMinutes
        #expect(duration == 23 * TimeRange.minutesPerHour)
    }
}
