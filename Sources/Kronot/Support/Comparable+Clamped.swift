//
//  Comparable+Clamped.swift
//  Kronot
//
//  Created by Fabio Floris on 09/04/2026.
//

import SwiftUI

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
