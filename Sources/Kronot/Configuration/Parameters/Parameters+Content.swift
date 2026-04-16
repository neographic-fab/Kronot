//
//  Parameters+Content.swift
//  Kronot
//
//  Created by Fabio Floris on 13/04/2026.
//

import SwiftUI

/// Content parameters used by Kronot rendering.
///
/// `Parameters.Content` groups options that affect the textual and accessory
/// elements of the component:
/// - `radialLabels`: radial label content, such as label frequency and meridiem visibility
/// - `readout`: accessory content shown in the start and end readout panels
///
/// Example:
/// ```swift
/// Kronot(...)
///     .parameters { params in
///         params.content.radialLabels.showMeridiem = true
///         params.content.radialLabels.frequency = .everyTwoHours
///         params.content.readout.start = .icon(systemName: "sun.max.fill")
///         params.content.readout.end = .icon(systemName: "moon.fill")
///     }
/// ```
public extension Parameters {
    struct Content {
        /// Content options for radial labels.
        public var radialLabels: RadialLabels = .init()
        
        /// Content options for readout accessories.
        public var readout: Readout = .init()
    }
}

// MARK: - Radial Label Parameters
public extension Parameters.Content {
    /// Content options for radial labels.
    ///
    /// - `showMeridiem`: controls whether AM/PM markers are shown, when supported by the formatter
    /// - `frequency`: controls how often labels are displayed around the dial
    ///
    /// - Note: The effective label frequency may be adjusted at runtime to account for Dynamic Type.
    struct RadialLabels {
        /// Whether meridiem markers (AM/PM) should be shown in radial labels.
        public var showMeridiem: Bool = false
        
        /// Frequency used to place labels around the dial.
        public var frequency: Frequency = .everyHour
       
        /// Label frequency around the dial.
        public enum Frequency {
            /// Displays one label for every hour.
            case everyHour
            
            /// Displays one label every two hours.
            case everyTwoHours
            
            /// Displays only cardinal hours (`0`, `6`, `12`, `18`).
            case cardinal
        }
    }
}

// MARK: - Readout Parameters
public extension Parameters.Content {
    /// Content options for readout panels.
    ///
    /// `Readout` allows a distinct accessory to be configured for the start
    /// and end readout panels.
    ///
    /// Example:
    /// ```swift
    /// params.content.readout.start = .verbatim("From")
    /// params.content.readout.end = .icon(systemName: "flag.checkered")
    /// ```
    struct Readout {
        /// Visual accessories displayed alongside readout values.
        public enum Accessory {
            /// No accessory.
            case none
            
            /// Localized text shown alongside the readout value.
            case text(LocalizedStringResource)
            
            /// Verbatim text shown alongside the readout value.
            case verbatim(String)
            
            /// SF Symbols icon shown alongside the readout value.
            case icon(systemName: String)
        }
        
        /// Accessory used by the start readout.
        public var start: Accessory = .text(.readoutTimeStart)
        
        /// Accessory used by the end readout.
        public var end: Accessory = .text(.readoutTimeEnd)
        
        /// Returns the accessory configured for the specified reference.
        ///
        /// - Parameter reference: The target reference, either `.start` or `.end`.
        /// - Returns: The configured accessory, or `nil` when the value is `.none`.
        func accessory(for reference: RangeReference) -> Accessory? {
            let value = reference == .start ? start : end
            if case .none = value { return nil }
            return value
        }
    }
}
