//
//  RadialLayout.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Describes the base geometry of the Kronot dial.
///
/// `RadialLayout` groups the geometric values used to draw the component:
/// - reference size
/// - center point
/// - side length and radius
/// - fraction-to-angle conversion
///
/// It does not contain styling or interaction logic.
struct RadialLayout {
    let referenceSize: CGSize
    let zeroAngle: Angle = .degrees(-90)
}

// MARK: - Base Geometry
extension RadialLayout {
    /// Shortest side used as the geometric base of the dial.
    var side: CGFloat {
        min(referenceSize.width, referenceSize.height)
    }
    
    /// Center point of the dial within the reference surface.
    var center: CGPoint {
        .init(x: side * 0.5, y: side * 0.5)
    }
    
    /// Base radius of the dial.
    var radius: CGFloat { side * 0.5 }
    
    /// Returns a radius reduced by the specified inset.
    ///
    /// This is useful when an element needs to be drawn farther inside
    /// the outer edge of the dial.
    ///
    /// - Parameter inset: The inward inset to apply.
    /// - Returns: A non-negative radius reduced by the given inset.
    func radius(insetBy inset: CGFloat) -> CGFloat {
        max(.zero, radius - inset)
    }
    
    /// Converts a day fraction into an angle on the dial.
    ///
    /// The expected fraction is in the `0...1` range, where:
    /// - `0`   = start of day
    /// - `0.5` = middle of day
    /// - `1`   = end of day, which wraps back to `0`
    ///
    /// The dial always uses a top-centered zero position.
    ///
    /// - Parameter fraction: The fraction of the day to convert.
    /// - Returns: The corresponding angle on the dial.
    func angle(for fraction: Double) -> Angle {
        zeroAngle + .degrees(360.0 * fraction)
    }
}

// MARK: - Layer Radii
extension RadialLayout {
    /// Radius of the track centerline, derived from `lineWidth` and `inset`.
    func arcRadius(using tokens: DesignTokens) -> CGFloat {
        radius(insetBy: tokens.track.inset + (tokens.track.lineWidth * 0.5))
    }
    
    /// Radius used for tick marks, derived from the track width and inset.
    func tickRadius(using tokens: DesignTokens) -> CGFloat {
        let trackWidth = tokens.track.lineWidth
        let trackInset = tokens.track.inset
        return radius(insetBy: (trackWidth + trackInset) + tokens.tick.inset)
    }
    
    /// Radius used for radial labels, positioned inward from the major tick marks.
    ///
    /// - Parameter inset: Additional inward spacing applied to the labels.
    /// - Returns: The radius used to place radial labels.
    func radialLabelRadius(using tokens: DesignTokens, inset: CGFloat) -> CGFloat {
        let tickMajorLength = tokens.tick.major.length
        let tickRadius = tickRadius(using: tokens)
        return max(.zero, tickRadius - tickMajorLength - inset)
    }
    
    /// Radius used for drag handles, derived from the track width and inset.
    func thumbRadius(using tokens: DesignTokens) -> CGFloat {
        radius(insetBy: (tokens.track.lineWidth * 0.5) + tokens.track.inset)
    }
}
