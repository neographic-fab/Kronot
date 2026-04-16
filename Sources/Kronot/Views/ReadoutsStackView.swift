//
//  ReadoutsStack.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Stato di focus dei pannelli di lettura.
///
/// - `.idle`: mostra durata e nasconde start/end in accessibilità alta.
/// - `.focused(Reference)`: evidenzia il readout del riferimento attivo.
enum ReadoutsFocus: Equatable {
    case idle, focused(RangeReference)
    init(target: DragTarget) {
        switch target {
        case .reference(let reference): self = .focused(reference)
        case .idle, .range: self = .idle
        }
    }
}

/// Visualizza i pannelli di lettura (start, durata, end) con aspetto derivato dai token.
///
/// - Parameters:
///   - focus: Stato di focus che decide quali elementi mostrare/evidenziare.
///   - formatter: Formatter responsabile di testo e localizzazione.
///   - range: Intervallo attuale.
///
/// Note:
/// - Adatta la visibilità in base al `DynamicTypeSize`.
/// - Usa i token `readouts` per tipografia e colori.
struct ReadoutsStackView: View {
    let focus: ReadoutsFocus
    let formatter: KronotFormatter
    let range: TimeRange
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @ScaledMetric(relativeTo: .title3) private var stackSpacing = 16.0

    var body: some View {
        VStack(spacing: stackSpacing) {
            if shouldShow(.start) {
                let startText = formatter.timeText(for: range.start)
                Text(startText)
                    .resolved(appearance(for: .start))
            }
            
            if focus == .idle {
                Text(formatter.durationText(for: range))
                    .font(tokens.readouts.duration.font)
                    .fontWeight(tokens.readouts.duration.fontWeight)
            }
            
            if shouldShow(.end) {
                let endText = formatter.timeText(for: range.end)
                Text(endText)
                    .resolved(appearance(for: .end))
            }
        }
    }
}

private typealias Appearance = DesignTokens.ReadoutsTokens.Appearance

private extension ReadoutsStackView {

    /// Indica se il Dynamic Type corrente è in modalità accessibilità.
    var isAccessible: Bool {
        dynamicTypeSize >= .accessibility1
    }

    /// Determina se mostrare il readout per il riferimento indicato.
    func shouldShow(_ reference: RangeReference) -> Bool {
        switch focus {
        case .focused(let ref): return ref == reference
        case .idle: return !isAccessible
        }
    }
        
    /// Restituisce l'aspetto tipografico per il riferimento, in base al focus.
    func appearance(for reference: RangeReference) -> Appearance {
        let state: DesignTokens.ReadoutsTokens.FocusState = reference == .start ? tokens.readouts.start : tokens.readouts.end
        
        switch focus {
        case .focused(let ref):
            return ref == reference ?
            state.focused : state.idle
            
        case .idle: return state.idle
        }
    }
}

private extension View {
    /// Applica font, peso e colore a partire da un'`Appearance`.
    func resolved(_ appearance: Appearance) -> some View {
        self
            .font(appearance.font)
            .fontWeight(appearance.fontWeight)
            .foregroundStyle(appearance.color)
    }
}


#Preview {
    @Previewable @State var range: TimeRange = .currentTime()
   Kronot(range: $range)
        .dynamicTypeSize(.accessibility4)
}

