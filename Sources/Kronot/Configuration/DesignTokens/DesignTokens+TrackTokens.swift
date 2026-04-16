//
//  DesignTokens+TrackTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 11/04/2026.
//

import SwiftUI

/// Describes the visual content used to draw a track stroke.
///
/// `TrackStyle` does not define stroke width, line caps, or markers.
/// Those aspects are configured by the caller, for example through `stroke(style:)`.
/// Its responsibility is limited to the visual content of the stroke itself,
/// such as a solid color or an angular gradient.
///
/// Examples:
/// ```swift
/// // Solid color
/// let style1: TrackStyle = .solid(.blue)
///
/// // Centered angular gradient
/// let style2: TrackStyle = .angular(.red, .orange, .yellow)
/// ```
public enum TrackStyle {
    /// Applies a solid color to the track stroke.
    ///
    /// - Parameter color: The color used to draw the stroke.
    case solid(Color)
    
    /// Applies an angular gradient along the track stroke.
    ///
    /// - Parameters:
    ///   - colors: The ordered list of colors used by the gradient. Requires at least two colors.
    ///   - center: The center point of the angular gradient. Defaults to `.center`.
    case angularGradient(colors: [Color], center: UnitPoint)
    
    /// Creates an angular gradient style using a concise variadic syntax.
    ///
    /// At least two colors are required to produce a visible transition.
    /// A precondition failure is triggered otherwise.
    ///
    /// - Parameters:
    ///   - colors: Variadic list of colors used by the gradient. Requires at least two colors.
    ///   - center: The center point of the angular gradient. Defaults to `.center`.
    ///
    /// - Returns: A `TrackStyle.angularGradient` configured with the provided values.
    static func angular(_ colors: Color..., center: UnitPoint = .center) -> Self {
        precondition(colors.count >= 2, "TrackStyle requires at least 2 colors")
        return .angularGradient(colors: colors, center: center)
    }
}

public extension DesignTokens {
    /// Visual tokens used by the track layer.
    ///
    /// `TrackTokens` contains rendering-related configuration for the circular track:
    /// - stroke width (`lineWidth`)
    /// - inward inset (`inset`)
    /// - line ending style (`lineCap`)
    /// - marker visibility and appearance
    /// - visual styles for the base and active segments
    struct TrackTokens {
        /// Stroke width of the track.
        public var lineWidth: CGFloat = 20.0
        
        /// Inset applied to the track toward the inside of the dial.
        public var inset: CGFloat = .zero
        
        /// Line cap style used by the track stroke.
        public var lineCap: CGLineCap = .round

        /// Whether markers are shown for the active segment.
        public var showMarker: Bool = true
        
        /// Length factor of the markers relative to the track width.
        public var markerLengthFactor: CGFloat = 0.3
        
        /// Stroke width used by the markers.
        public var markerLineWidth: CGFloat = 2.0
        
        /// Color of the markers.
        public var markerColor: Color = .white.opacity(0.5)
        
        /// Visual style used by the base track segment.
        private var baseStyle: TrackStyle = .solid(.secondary.opacity(0.2))
        
        /// Visual style used by the active track segment.
        private var rangeStyle: TrackStyle = .angular(.green, .red)
    }
}

public extension DesignTokens.TrackTokens {
    /// Role of the track segment associated with a style.
    enum Role {
        /// Passive base segment of the track.
        case base
        
        /// Active segment representing the selected range.
        case range
    }

    /// Returns the style configured for the specified role.
    ///
    /// - Parameter role: The target role, either `.base` or `.range`.
    /// - Returns: The style associated with the given role.
    func style(for role: Role) -> TrackStyle {
        switch role {
        case .base: return baseStyle
        case .range: return rangeStyle
        }
    }
    
    /// Sets the style for the specified role.
    ///
    /// Example:
    /// ```swift
    /// var tokens = DesignTokens().track
    /// tokens.setStyle(.solid(.blue), for: .base)
    /// tokens.setStyle(.angular(.green, .red), for: .range)
    /// ```
    ///
    /// - Parameters:
    ///   - style: The new style to apply.
    ///   - role: The target role, either `.base` or `.range`.
    mutating func setStyle(_ style: TrackStyle, for role: Role) {
        switch role {
        case .base: baseStyle = style
        case .range: rangeStyle = style
        }
    }
}

extension DesignTokens.TrackTokens {
    /// Returns a sanitized copy of the track tokens.
    ///
    /// Applied rules:
    /// - `lineWidth` is clamped to `4.0...50.0`
    /// - `inset` is clamped to a non-negative value
    /// - `markerLineWidth` is clamped to a minimum of `1.0`
    /// - `markerLengthFactor` is clamped to `0.1...1.0`
    ///
    /// - Returns: A sanitized copy of `TrackTokens`, ready for rendering.
    func sanitized() -> Self {
        var copy = self
        copy.lineWidth = copy.lineWidth.clamped(to: 4.0...50.0)
        copy.inset = max(.zero, copy.inset)
        copy.markerLineWidth = max(1.0, copy.markerLineWidth)
        copy.markerLengthFactor = copy.markerLengthFactor.clamped(to: 0.1...1.0)
        return copy
    }
}
