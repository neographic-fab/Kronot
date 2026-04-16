//
//  Track.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Disegna la geometria dell'arco di Kronot.
///
/// `TrackShape` può rappresentare:
/// - il track completo
/// - il range attivo
///
/// Non contiene logica di stile, gesture o formattazione.
private struct TrackShape: InsettableShape {
    
    enum Role {
        /// Disegna il cerchio completo del track.
        case track
        /// Disegna l'intervallo attivo del range.
        /// Le frazioni sono attese nel range `0...1` e vengono mappate ad angoli
        /// tramite `layout.angle(for:)`. Il tracciamento dell'arco avviene in senso antiorario.
        case range(_ startFraction: Double, _ endFraction: Double)
    }
    
    let role: Role
    let layout: RadialLayout
    var insetAmount: CGFloat = .zero
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
    
    func path(in rect: CGRect) -> Path {
        let angles = resolvedAngles()
        var path = Path()
        path.addArc(center: layout.center,
                    radius: layout.radius(insetBy: insetAmount),
                    startAngle: angles.start,
                    endAngle: angles.end,
                    clockwise: false)
        return path
    }
}

private extension TrackShape {
    /// Restituisce gli angoli effettivi usati per disegnare la shape.
    /// - Per il track, copre l'intero giro del quadrante (fractions 0 → 1).
    /// - Per il range, calcola `start` ed `end` mappando le frazioni `0...1` tramite
    ///   `layout.angle(for:)`, e disegna l'arco tra i due angoli in senso antiorario.
    func resolvedAngles() -> (start: Angle, end: Angle) {
        switch role {
        case .track: return (start: layout.angle(for: .zero), end: layout.angle(for: 1.0))
        case let .range(startFraction, endFraction):
            let startAngle = layout.angle(for: startFraction)
            let endAngle = layout.angle(for: endFraction)
            return (start: startAngle, end: endAngle)
        }
    }
}


/// Disegna il layer dell'arco di Kronot:
/// - track completo
/// - range attivo
///
/// `TrackView` riceve valori già pronti per il rendering.
/// Non contiene logica di dominio, gesture o formattazione.
/// `TrackView` assume di essere disegnato in uno spazio coerente con `layout.referenceSize`.
/// Nelle preview o negli usi isolati, applicare un frame compatibile con il layout passato.
struct TrackView: View {
    let layout: RadialLayout
    let fractions: (start: Double, end: Double)
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    var body: some View {
        Group {
            TrackShape(role: .track, layout: layout)
                .inset(by: tokens.track.inset)
                .strokeBorder(trackShapeStyle, style: strokeStyle)
                
            TrackShape(role: .range(fractions.start, fractions.end), layout: layout)
            .inset(by: tokens.arc.inset)
            .strokeBorder(rangeShapeStyle, style: strokeStyle)
            .overlay {
                if tokens.arc.showMarker || differentiateWithoutColor {
                    // TODO: Reintroduce marker when available (ArcMarker/TrackMarker).
                    // ArcMarker(layout: layout, fractions: fractions)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private extension TrackView {
    var strokeStyle: StrokeStyle {
        .init(lineWidth: tokens.track.lineWidth, lineCap: tokens.arc.lineCap)
    }
    /// Restituisce gli angoli usati per disegnare il track completo.
    var trackAngles: (start: Angle, end: Angle) {
        let start = layout.zeroAngle
        let end = start + .degrees(360.0)
        return (start, end)
    }
    /// Restituisce gli angoli del range attivo a partire dalle frazioni già risolte.
    var rangeAngles: (start: Angle, end: Angle) {
        let start = layout.angle(for: fractions.start)
        var delta = fractions.end - fractions.start

        if delta < .zero { delta += 1 }

        let end = start + .degrees(360.0 * delta)
        return (start, end)
    }
    /// Converte `ArcStyle` nello `ShapeStyle` concreto usato per lo stroke.
    ///
    /// Per i gradienti angolari usa gli angoli già risolti dal chiamante.
    func shapeStyle(_ style: ArcStyle, angles: (start: Angle, end: Angle)) -> AnyShapeStyle {
        switch style {
        case .solid(let color): return AnyShapeStyle(color)
        case .angularGradient(let colors, let center):
            return AnyShapeStyle(
                AngularGradient(colors: colors, center: center, startAngle: angles.start, endAngle: angles.end)
            )
        }
    }
    var trackShapeStyle: AnyShapeStyle {
        shapeStyle(tokens.track.trackArcStyle, angles: trackAngles)
    }
    
    var rangeShapeStyle: AnyShapeStyle {
        shapeStyle(tokens.track.rangeArcStyle, angles: rangeAngles)
    }
}

#Preview {
    let layout = RadialLayout(
        referenceSize: .init(width: 300, height: 300)
    )

    TrackView(
        layout: layout,
        fractions: (start: 0.2, end: 0.8)
    )
    .designTokens { tokens in
        tokens.track.lineWidth = 24
        tokens.track.inset = 12
        tokens.track.trackArcStyle = .solid(.gray.opacity(0.25))
        tokens.track.rangeArcStyle = .angular(Color.green, Color.red)
    }
    .frame(width: 300, height: 300)
}

