//
//  ModelDatastorageCity.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Datastorage {
    
    internal struct City: Codable {
        
        internal let from: Model.Service.Location
        internal let to: Model.Service.Location
        
        internal let date: Date
        
        internal init(
            from: Model.Service.Location
            , to: Model.Service.Location
            , date: Date = .init()
        )
        {
            self.from = from
            self.to = to
            self.date = date
        }
        
    }
    
}
