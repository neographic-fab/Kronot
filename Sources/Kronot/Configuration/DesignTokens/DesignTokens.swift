//
//  DesignTokens.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import SwiftUI

/// Collection of visual design tokens used by Kronot.
///
/// `DesignTokens` groups the styling subsets that define the visual appearance
/// of the component:
/// - `track`: appearance of the main circular track and its marker
/// - `tick`: styling for major and minor tick marks
/// - `radialLabels`: typography, color, and visibility for radial labels
/// - `thumb`: appearance and sizing for drag controls
/// - `readouts`: typography and spacing for the readout panel
///
/// Use `sanitized()` to normalize numeric values and keep rendering consistent.
public struct DesignTokens {
    /// Design tokens for the main track.
    public var track: TrackTokens = .init()
    
    /// Design tokens for major and minor tick marks.
    public var tick: TickTokens = .init()
    
    /// Design tokens for radial labels.
    public var radialLabels: RadialLabelsTokens = .init()
    
    /// Design tokens for drag controls.
    public var thumb: ThumbTokens = .init()
    
    /// Design tokens for readout panels.
    public var readouts: ReadoutsTokens = .init()
}

// MARK: - Sanitization
extension DesignTokens {
    /// Returns a copy of the tokens with all subsets sanitized.
    ///
    /// Each subset applies its own `sanitized()` logic to normalize numeric values
    /// and preserve visual consistency.
    ///
    /// - Returns: A sanitized copy of `DesignTokens`, ready for rendering.
    func sanitized() -> Self {
        var copy = self
        copy.track = copy.track.sanitized()
        copy.tick = copy.tick.sanitized()
        copy.radialLabels = copy.radialLabels.sanitized()
        copy.thumb = copy.thumb.sanitized()
        return copy
    }
}
