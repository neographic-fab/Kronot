//
//  TickView.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Layer responsible for drawing tick marks around the dial.
///
/// Tick density is derived from the configured snapping mode,
/// while size and color are provided by `DesignTokens`.
///
/// Tick marks are decorative:
/// - they do not expose information to VoiceOver
/// - they do not depend on Dynamic Type
/// - they read styling and density from the environment
///
/// Notes:
/// - tick density depends on `parameters.behavior.snapMode`
/// - radius is derived through `layout.tickRadius(using:)`
struct TickView: View {
    let layout: RadialLayout
    
    @Environment(\.designTokens) private var tokens
    @Environment(\.parameters) private var parameters
    
    /// Number of tick marks drawn for each hour.
    var ticksPerHour: Int {
        max(1, TimeRange.minutesPerHour / parameters.behavior.snapMode.value)
    }
    
    /// Total number of tick marks drawn across the full day.
    var ticksPerDay: Int {
        TimeRange.hoursPerDay * ticksPerHour
    }
    
    var body: some View {
        Canvas { ctx, _ in
            ctx.translateBy(x: layout.center.x, y: layout.center.y)
            let radius = layout.tickRadius(using: tokens)
            
            for index in 0..<ticksPerDay {
                let tick = Tick(index: index, tickPerHour: ticksPerHour)
                let fraction = Double(index) / Double(ticksPerDay)
                let angle = layout.angle(for: fraction)
                let style = tick.style(using: tokens)
                
                var path = Path()
                path.move(to: .init(x: radius - style.length, y: .zero))
                path.addLine(to: .init(x: radius, y: .zero))
                
                ctx.drawLayer { layer in
                    layer.rotate(by: angle)
                    layer.stroke(path, with: .color(style.color), lineWidth: style.width)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Tick Classification
extension TickView {
    /// Tick kind derived from its position relative to the hour.
    enum Tick {
        case major
        case minor
        
        /// Resolves the tick kind from the global index and current density.
        ///
        /// - Parameters:
        ///   - index: Tick index within the full day.
        ///   - tickPerHour: Number of tick marks drawn for each hour.
        init(index: Int, tickPerHour: Int) {
            self = index.isMultiple(of: tickPerHour) ? .major : .minor
        }
        
        /// Returns the appearance associated with the current tick kind.
        ///
        /// - Parameter tokens: The current design tokens.
        /// - Returns: The tick appearance, including length, width, and color.
        func style(using tokens: DesignTokens) -> DesignTokens.TickTokens.Appearance {
            switch self {
            case .major: return tokens.tick.major
            case .minor: return tokens.tick.minor
            }
        }
    }
}
