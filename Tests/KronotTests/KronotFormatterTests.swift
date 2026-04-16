//
//  KronotFormatterTests.swift
//  Kronot
//
//  Created by Fabio Floris on 15/04/2026.
//

import Testing
import Foundation
@testable import Kronot

@Suite("KronotFormatter: etichette radiali e formati orari")
struct KronotFormatterTests {
    @Test("24h: usa numeri locali per l'ora")
    func radialLabel_24h_usesLocalizedHourNumber() {
        // Given: locale 24h (it_IT), meridiem disattivo
        let formatter = KronotFormatter(locale: .init(identifier: "it_IT"), showMeridiem: false)
        // Then: le etichette radiali mostrano numeri 24h
        #expect(formatter.radialLabel(for: 0) == "0")
        #expect(formatter.radialLabel(for: 13) == "13")
    }

    @Test("12h senza meridiem: orologio a 12 ore")
    func radialLabel_12h_withoutMeridiem_uses12HourClock() {
        // Given: locale 12h (en_US), meridiem disattivo
        let formatter = KronotFormatter(locale: .init(identifier: "en_US"), showMeridiem: false)
        // Then: mappa 0→12 e 13→1 in formato 12h
        #expect(formatter.radialLabel(for: 0) == "12")
        #expect(formatter.radialLabel(for: 13) == "1")
    }

    @Test("12h con meridiem: AM/PM alle ore chiave")
    func radialLabel_12h_withMeridiem_returnAMPMAtKeyHour() {
        // Given: locale 12h (en_US), meridiem attivo
        let formatter = KronotFormatter(locale: .init(identifier: "en_US"), showMeridiem: true)
        // Then: alle ore chiave (0,12) mostra AM/PM
        #expect(formatter.radialLabel(for: 0) == "AM")
        #expect(formatter.radialLabel(for: 12) == "PM")
    }

    @Test("Locale.uses24h corrisponde alle aspettative note")
    func localeUses24h_matchesKnownLocales() {
        // Then: it_IT usa 24h, en_US usa 12h
        #expect(Locale(identifier: "it_IT").uses24h)
        #expect(!Locale(identifier: "en_US").uses24h)
    }
    
    @Test("timeText: output leggibile in it_IT")
    func timeText_returnsReadableOutput() {
        let formatter = KronotFormatter(locale: .init(identifier: "it_IT"), showMeridiem: false)
        // When: formatto un orario con minuti non multipli di 10
        let text = formatter.timeText(for: .init(hour: 8, minute: 5))

        #expect(!text.isEmpty)
    }
    
    @Test("durationText: range semplice non vuoto")
    func durationText_forSimpleRange_isNotEmpty() {
        let formatter = KronotFormatter(locale: .init(identifier: "en_US"), showMeridiem: false)
        // Given: un range semplice nello stesso giorno
        let range = TimeRange(start: .init(hour: 8, minute: 0), end: .init(hour: 10, minute: 0))
        let text = formatter.durationText(for: range)

        #expect(!text.isEmpty)
    }
    
    @Test("durationText: range wrappato non vuoto")
    func durationText_forWrappedRange_isNotEmpty() {
        let formatter = KronotFormatter(locale: .init(identifier: "it_IT"), showMeridiem: false)
        // Given: un range che attraversa la mezzanotte
        let range = TimeRange(start: .init(hour: 22, minute: 0), end: .init(hour: 1, minute: 30))
        let text = formatter.durationText(for: range)

        #expect(!text.isEmpty)
    }
}

