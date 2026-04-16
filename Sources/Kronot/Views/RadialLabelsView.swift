//
//  RadialLabelsView.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Draws the hour labels around the dial.
///
/// Label frequency and meridiem visibility are controlled by
/// `Parameters.Content.RadialLabels`.
/// Typography and color are provided by `DesignTokens.radialLabels`.
///
/// Accessibility:
/// - labels are decorative and hidden from VoiceOver
/// - label density may be reduced automatically at larger Dynamic Type sizes
struct RadialLabelsView: View {
    let layout: RadialLayout
    let formatter: KronotFormatter
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.parameters) private var parameters
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        // The canvas is translated to the dial center, rotated for each hour,
        // then translated outward and counter-rotated so the text stays upright.
        Canvas { ctx, _ in
            ctx.translateBy(x: layout.center.x, y: layout.center.y)
            let radius =  layout.radialLabelRadius(using: tokens, inset: inset)
            
            for hour in hours {
                let fraction = Double(hour) / Double(TimeRange.hoursPerDay)
                let angle = layout.angle(for: fraction)
                
                ctx.drawLayer { layer in
                    layer.rotate(by: angle)
                    layer.translateBy(x: radius, y: .zero)
                    layer.rotate(by: .degrees(-angle.degrees))
                    layer.draw(
                        formattedLabel(for: hour),
                        at: .zero,
                        anchor: .center
                    )
                }
            }
        }
        .dynamicTypeSize(...(.accessibility4))
        .accessibilityHidden(true)
    }
}

private extension RadialLabelsView {
    
    // MARK: - Derived Layout Values
    
    /// Sequence of hours to label, derived from the effective label frequency.
    var hours: [Int] {
        switch frequency {
        case .everyHour: Array(stride(from: .zero, to: 24, by: 1))
        case .everyTwoHours: Array(stride(from: .zero, to: 24, by: 2))
        case .cardinal: Array(stride(from: .zero, to: 24, by: 6))
        }
    }
    
    /// Effective label frequency, adapted to the current `DynamicTypeSize`.
    var frequency: Parameters.Content.RadialLabels.Frequency {
        let freq = parameters.content.radialLabels.frequency
        switch dynamicTypeSize {
        case ...(.large): return freq
        case .xLarge ... .accessibility1: return freq == .cardinal ? .cardinal : .everyTwoHours
        case (.accessibility2)... : return .cardinal
        default: return .cardinal
        }
    }
    
    /// Label inset relative to the tick ring, increased at larger Dynamic Type sizes.
    var inset: CGFloat {
        let baseInset = tokens.radialLabels.inset
        switch dynamicTypeSize {
        case ...(.large): return baseInset
        case .xLarge ... .accessibility2: return baseInset + 6.0
        case (.accessibility3)... : return baseInset + 12.0
        default: return baseInset
        }
    }
    
    // MARK: - Formatting
    
    /// Returns the formatted label for the specified hour, styled using the current tokens.
    ///
    /// - Parameter hour: The hour value to display.
    /// - Returns: A styled `Text` view for the radial label.
    func formattedLabel(for hour: Int) -> Text {
        Text(formatter.radialLabel(for: hour))
            .font(tokens.radialLabels.font)
            .foregroundStyle(tokens.radialLabels.color)
    }
}
