//
//  ReadoutsAccessoryView.swift
//  Kronot
//
//  Created by Fabio Floris on 13/04/2026.
//

import SwiftUI

/// Renders the readout accessory for the specified reference.
///
/// The accessory is configured through `Parameters.Content.Readout` and may be:
/// - `.none`: no accessory
/// - `.text(LocalizedStringResource)`: localized text
/// - `.verbatim(String)`: verbatim text
/// - `.icon(systemName:)`: SF Symbols icon
struct ReadoutsAccessoryView: View {
    /// Reference associated with the accessory, either start or end.
    let reference: RangeReference
    
    /// Environment parameters used by the component.
    @Environment(\.parameters) private var parameters
    
    /// Accessory resolved for the current reference.
    private var accessory: Parameters.Content.Readout.Accessory? {
        let resolved: Parameters.Content.Readout.Accessory
        switch reference {
        case .start: resolved = parameters.content.readout.start
        case .end: resolved = parameters.content.readout.end
        }
        
        if case .none = resolved { return nil }
        
        return resolved
    }
    
    /// Renders the accessory using the configured content type.
    @ViewBuilder
    var body: some View {
        if case let .text(string)? = accessory {
            Text(string)
        } else if case let .verbatim(string)? = accessory {
            Text(verbatim: string)
        } else if case let .icon(systemName)? = accessory {
            Image(systemName: systemName)
        }
    }
}
