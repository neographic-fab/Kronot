//
//  ReadoutsAccessoryView.swift
//  Kronot
//
//  Created by Fabio Floris on 13/04/2026.
//

import SwiftUI

/// View che renderizza l'accessorio del readout (start/end) in base ai parametri.
///
/// L'accessorio è configurabile tramite `Parameters.Content.Readout` e può essere:
/// - `.none`: nessun elemento
/// - `.text(String)`: testo descrittivo
/// - `.icon(systemName:)`: icona SF Symbols
struct ReadoutsAccessoryView: View {
    /// Riferimento a cui associare l'accessorio (start o end).
    let reference: RangeReference
    /// Parametri ambientali del componente.
    @Environment(\.parameters) private var parameters
    
    /// Accessorio risolto per il riferimento corrente.
    private var accessory: Parameters.Content.Readout.Accessory? {
        let resolved: Parameters.Content.Readout.Accessory
        switch reference {
        case .start: resolved = parameters.content.readout.start
        case .end: resolved = parameters.content.readout.end
        }
        
        if case .none = resolved {
            return nil
        }
        
        return resolved
    }
    
    /// Corpo della view: renderizza l'accessorio in base al tipo configurato.
    var body: some View {
        if case let .text(string)? = accessory {
            Text(string)
        } else if case let .icon(systemName)? = accessory {
            Image(systemName: systemName)
        }
    }
}
