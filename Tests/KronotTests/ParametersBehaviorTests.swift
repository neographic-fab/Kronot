//
//  ParametersBehaviorTests.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Testing
@testable import Kronot

@Suite("Parameters.Behavior: default, sanitizzazione e snap")
struct ParametersBehaviorTests {
    @Test("Valori di default attesi")
    func behavior_defaultValues_areExpected() {
        // Given: un Behavior appena inizializzato
        let behavior = Parameters.Behavior()
        // Then: i valori di default sono coerenti
        #expect(behavior.minActiveHours == 1)
        #expect(behavior.maxActiveHours == 20)
        #expect(behavior.snapMode == .everyQuarterHour)
    }

    @Test("sanitized() clampa i bound nel range valido")
    func sanitized_clampBehaviorBoundsToValidRange() {
        // Given: bound fuori intervallo
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = -4
        behavior.maxActiveHours = 99
        // When
        let sanitized = behavior.sanitized()
        // Then: valori clampati
        #expect(sanitized.minActiveHours == 1)
        #expect(sanitized.maxActiveHours == 23)
    }

    @Test("sanitized() impedisce a min di superare max")
    func sanitized_preventsMinFromExceedingMax() {
        // Given: min > max
        var behavior = Parameters.Behavior()
        behavior.minActiveHours = 10
        behavior.maxActiveHours = 4
        // When
        let sanitized = behavior.sanitized()
        // Then: entrambi allineati a 4
        #expect(sanitized.minActiveHours == 4)
        #expect(sanitized.maxActiveHours == 4)
    }

    @Test("SnapMode espone i minuti attesi")
    func snapMode_exposesExpectedMinuteValues() {
        #expect(Parameters.Behavior.SnapMode.everyFiveMinutes.value == 5)
        #expect(Parameters.Behavior.SnapMode.everyTenMinutes.value == 10)
        #expect(Parameters.Behavior.SnapMode.everyQuarterHour.value == 15)
        #expect(Parameters.Behavior.SnapMode.everyHalfHour.value == 30)
        #expect(Parameters.Behavior.SnapMode.everyHour.value == 60)
    }
}
