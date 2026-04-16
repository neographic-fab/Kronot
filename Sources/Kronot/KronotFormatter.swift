//
//  KronotFormatter.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import Foundation

/// Formatter per le stringhe testuali di Kronot (etichette radiali, orari, durate).
///
/// Centralizza la formattazione locale per le letture e per le etichette del quadrante.
struct KronotFormatter {
    private let locale: Locale
    private let showMeridiem: Bool
    private var calendar: Calendar = .current
    
    /// Crea un formatter con la locale e la preferenza per il meridiem.
    ///
    /// - Parameters:
    ///   - locale: La locale usata per la formattazione di numeri e orari.
    ///   - showMeridiem: Indica se mostrare le etichette AM/PM nei formati a 12 ore.
    init(locale: Locale, showMeridiem: Bool) {
        self.locale = locale
        self.showMeridiem = showMeridiem
        calendar.locale = locale
    }
    
    /// Restituisce l'etichetta radiale per l'ora indicata.
    ///
    /// L'etichetta rispetta la preferenza 24h della locale e, se configurato,
    /// usa i simboli AM/PM.
    ///
    /// - Parameter hour: L'ora in formato 24h (0-23).
    /// - Returns: Un'etichetta localizzata per il tick radiale.
    func radialLabel(for hour: Int) -> String {
        if locale.uses24h { return localizedNumber(hour) }
        
        if showMeridiem {
            let formatter = DateFormatter()
            formatter.locale = locale
            let am = (formatter.amSymbol?.isEmpty == false ? formatter.amSymbol : nil) ?? "AM"
            let pm = (formatter.pmSymbol?.isEmpty == false ? formatter.pmSymbol : nil) ?? "PM"
            
            if hour == .zero { return am }
            if hour == 12 { return pm }
        }
        
        let hour12 = (hour % 12 == .zero) ? 12 : (hour % 12)
        
        return localizedNumber(hour12)
    }
    
    /// Restituisce il numero formattato secondo la locale.
    ///
    /// - Parameter value: Il valore intero da formattare.
    /// - Returns: Una stringa decimale localizzata.
    private func localizedNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

extension KronotFormatter {
    /// Restituisce il testo orario formattato per i componenti indicati.
    ///
    /// - Parameter components: Componenti di ora e minuto da formattare.
    /// - Returns: Una stringa oraria localizzata.
    func timeText(for components: TimeRange.Components) -> String {
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        let date = calendar.date(from: dateComponents) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Restituisce il testo della durata (ore e minuti) per l'intervallo.
    ///
    /// L'output omette i componenti a zero.
    ///
    /// - Parameter range: L'intervallo da riassumere.
    /// - Returns: Una durata abbreviata e localizzata.
    func durationText(for range: TimeRange) -> String {
        let clampedMinutes = max(.zero, range.durationGoingForwardInMinutes)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.calendar = calendar
        let seconds = TimeInterval(clampedMinutes * TimeRange.minutesPerHour)
        return formatter.string(from: seconds) ?? ""
    }
}

extension Locale {
    /// Indica se la locale usa il formato orario a 24 ore.
    ///
    /// - Returns: `true` se la locale usa il formato 24h, altrimenti `false`.
    var uses24h: Bool {
        guard let format = DateFormatter.dateFormat(
            fromTemplate: "j",
            options: .zero,
            locale: self)
        else {
            return true
        }
        return !format.contains("a")
    }
}
