//
//  ObserverHandler.swift
//  IntechConsultingCoreKit
//
//  Created by Amine Bensalah on 15/03/2019.
//

import Foundation

public struct ObserverHandler<T> {
    public let id: UUID
    public let handler: T

    public init(_ id: UUID = UUID(), handler: T) {
        self.id = id
        self.handler = handler
    }
}

extension ObserverHandler: Equatable {
    public static func ==(lhs: ObserverHandler, rhs: ObserverHandler) -> Bool {
        return lhs.id == rhs.id
    }
}
