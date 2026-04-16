//
//  KronotFormatter.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026
//

import Foundation

/// Formatter used by Kronot for textual output.
///
/// `KronotFormatter` centralizes locale-aware formatting for:
/// - radial labels around the dial
/// - time readouts
/// - duration strings
struct KronotFormatter {
    private let locale: Locale
    private let showMeridiem: Bool
    private var calendar: Calendar = .current
    
    /// Creates a formatter with the specified locale and meridiem preference.
    ///
    /// - Parameters:
    ///   - locale: Locale used to format numbers and time values.
    ///   - showMeridiem: Whether AM/PM markers should be shown when using 12-hour formatting.
    init(locale: Locale, showMeridiem: Bool) {
        self.locale = locale
        self.showMeridiem = showMeridiem
        calendar.locale = locale
    }
    
    /// Returns the radial label for the specified hour.
    ///
    /// The label respects the locale’s 24-hour preference and,
    /// when enabled, may use localized AM/PM symbols.
    ///
    /// - Parameter hour: Hour in 24-hour format (`0...23`).
    /// - Returns: A localized radial label string.
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
    
    /// Returns a number formatted according to the current locale.
    ///
    /// - Parameter value: Integer value to format.
    /// - Returns: A localized decimal string.
    private func localizedNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

extension KronotFormatter {
    
    // MARK: - Time Formatting
    
    /// Returns a localized time string for the provided components.
    ///
    /// - Parameter components: Hour and minute components to format.
    /// - Returns: A localized short time string.
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
    
    /// Returns a localized duration string for the given range.
    ///
    /// The output uses abbreviated units and omits zero-valued components.
    ///
    /// - Parameter range: Range whose duration should be formatted.
    /// - Returns: A short localized duration string.
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
    /// Returns whether the locale uses a 24-hour time format.
    ///
    /// The result is derived from the locale’s date formatting template.
    ///
    /// - Returns: `true` when the locale uses 24-hour time, otherwise `false`.
    var uses24h: Bool {
        guard let format = DateFormatter.dateFormat(
            fromTemplate: "j",
            options: .zero,
            locale: self
        ) else {
            return true
        }
        
        return !format.contains("a")
    }
}
