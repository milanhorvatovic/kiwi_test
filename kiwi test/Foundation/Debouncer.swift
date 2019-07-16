//
//  Debouncer.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal final class Debouncer {
    
    private let queue: DispatchQueue = .main
    private var workItem: DispatchWorkItem = .init(block: {})
    private var interval: TimeInterval
    
    internal init(seconds: TimeInterval) {
        self.interval = seconds
    }
    
    // MARK: - Debouncing function
    internal func debounce(action: @escaping (() -> Void)) {
        self.workItem.cancel()
        self.workItem = DispatchWorkItem(block: { action() })
        self.queue.asyncAfter(deadline: .now() + self.interval, execute: self.workItem)
    }
    
}
