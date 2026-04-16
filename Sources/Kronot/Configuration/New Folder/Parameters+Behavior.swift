//
//  Parameters+Behavior.swift
//  Kronot
//
//  Created by Fabio Floris on 10/04/2026.
//

import Foundation

public extension Parameters {
    struct Behavior {
        public var minActiveHours: Int = 1
        public var maxActiveHours: Int = 20
    }
}

extension Parameters.Behavior {
    /// Restituisce una copia dei parametri riportata in uno stato coerente.
    ///
    /// Regole:
    /// - `minActiveHours` e `maxActiveHours` restano sempre tra 1 e 23
    /// - `minActiveHours` non può superare `maxActiveHours`
    func sanitized() -> Self {
        var copy = self
        copy.minActiveHours = copy.minActiveHours.clamped(to: 1...23)
        copy.maxActiveHours = copy.maxActiveHours.clamped(to: 1...23)
        copy.minActiveHours = min(copy.minActiveHours, copy.maxActiveHours)
        return copy
    }
}
