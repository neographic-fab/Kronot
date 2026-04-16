//
//  TimeRange.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import SwiftUI

/// Rappresenta l'intervallo attivo di Kronot.
///
/// `TimeRange` descrive la coppia di valori usata dal controllo:
/// - start
/// - end
///
/// Il modello pubblico resta leggibile:
/// chi usa Kronot lavora con `hour` e `minute`.
///
/// Internamente il package può costruire i valori anche
/// a partire dai minuti totali, così gesture, snap, wrap
/// e durata restano semplici da gestire.
public struct TimeRange: Equatable {
    public var start: Components
    public var end: Components
    
    /// Crea un intervallo con i componenti di inizio e fine.
    ///
    /// - Parameters:
    ///   - start: Componenti orari di inizio.
    ///   - end: Componenti orari di fine.
    public init(start: Components, end: Components) {
        self.start = start
        self.end = end
    }
    
    /// Crea un intervallo a partire dall'orario corrente, applicando uno snap.
    ///
    /// - Parameter snapHours: Ore da aggiungere all'orario corrente per calcolare la fine.
    /// - Returns: Un intervallo con `start` all'ora attuale e `end` avanzato di `snapHours`.
    public static func currentTime(snapHours: Int = 5) -> Self {
        let safeSnap = snapHours.clamped(to: 1...23)
        let now = Date()
        let start = Components(date: now)
        let end = Components(totalMinutes: start.minutesSinceMidnight + safeSnap * minutesPerHour)
        return Self(start: start, end: end)
    }
    
    /// Riporta un valore di minuti nel range valido della giornata.
    ///
    /// - Parameter minutes: Minuti (anche fuori range) da normalizzare.
    /// - Returns: Minuti compresi in `0..<minutesPerDay`.
    static func wrap(minutes: Int) -> Int {
        ((minutes % minutesPerDay) + minutesPerDay) % minutesPerDay
    }
    
    /// Minuti contenuti in un'ora.
    static let minutesPerHour = 60
    /// Ore contenute in un giorno.
    static let hoursPerDay = 24
    /// Minuti contenuti in un giorno.
    static let minutesPerDay = hoursPerDay * minutesPerHour
    
    /// Restituisce la durata dell'intervallo andando sempre in avanti.
    ///
    /// Se `end` è minore di `start`, il calcolo attraversa la mezzanotte.
    ///
    /// Esempi:
    /// - 08:00 -> 10:00 = 120
    /// - 22:00 -> 01:00 = 180
    var durationGoingForwardInMinutes: Int {
        let startMinutes = start.minutesSinceMidnight
        let endMinutes = end.minutesSinceMidnight
        
        if endMinutes >= startMinutes {
            return endMinutes - startMinutes
        } else {
            return (Self.minutesPerDay - startMinutes) + endMinutes
        }
    }
    /// Restituisce la frazione del giorno per `start`.
    ///
    /// Il valore è compreso tra 0 e 1.
    var startFractionOfDay: Double {
        let startFraction = Double(start.minutesSinceMidnight) / Double(Self.minutesPerDay)
        return startFraction.wrappedUnit
    }
    /// Restituisce la frazione del giorno per `end`.
    ///
    /// Il valore è compreso tra 0 e 1.
    var endFractionOfDay: Double {
        let endFraction = Double(end.minutesSinceMidnight) / Double(Self.minutesPerDay)
        return endFraction.wrappedUnit
    }
}

extension Double {
    /// Riporta una frazione nel range `0..<1`.
    ///
    /// Esempi:
    /// - `1.2`  -> `0.2`
    /// - `-0.1` -> `0.9`
    var wrappedUnit: Self {
        let remainder = truncatingRemainder(dividingBy: 1)
        return remainder >= .zero ? remainder : remainder + 1
    }
}

// MARK: - Components
public extension TimeRange {
    /// Rappresenta un singolo valore orario usato da `TimeRange`.
    ///
    /// Pubblicamente espone:
    /// - `hour`
    /// - `minute`
    ///
    /// Non conserva `totalMinutes` come storage:
    /// i minuti da mezzanotte vengono ricavati al bisogno.
    struct Components: Equatable {
        public var hour: Int
        public var minute: Int
        /// Crea un valore orario coerente a partire da ora e minuto.
        ///
        /// I valori vengono riportati in un orario valido della giornata.
        ///
        /// - Parameters:
        ///   - hour: Ora (0-23).
        ///   - minute: Minuto (0-59).
        public init(hour: Int, minute: Int) {
            let totalMinutes = (hour * TimeRange.minutesPerHour) + minute
            self.init(totalMinutes: totalMinutes)
        }
        /// Crea un valore orario a partire dai minuti totali della giornata.
        ///
        /// Questo init resta interno al package:
        /// serve per gesture, snap, wrap e calcoli interni.
        ///
        /// - Parameter totalMinutes: Minuti totali da mezzanotte (anche fuori range).
        init(totalMinutes: Int) {
            let wrappedMinute = TimeRange.wrap(minutes: totalMinutes)
            self.hour = wrappedMinute / TimeRange.minutesPerHour
            self.minute = wrappedMinute % TimeRange.minutesPerHour
        }
        /// Costruisce `TimeComponents` leggendo ora e minuto da una `Date`.
        ///
        /// Questo init resta interno al package:
        /// serve per costruire valori iniziali a partire dall'orario attuale.
        ///
        /// - Parameters:
        ///   - date: Data da cui leggere ora e minuto.
        ///   - calendar: Calendario usato per estrarre i componenti.
        init(date: Date, using calendar: Calendar = .current) {
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            self.init(hour: hour, minute: minute)
        }
        /// Restituisce i minuti trascorsi da mezzanotte.
        ///
        /// Esempi:
        /// - 00:00 -> 0
        /// - 01:30 -> 90
        /// - 23:59 -> 1439
        var minutesSinceMidnight: Int {
            hour * TimeRange.minutesPerHour + minute
        }
    }
}
