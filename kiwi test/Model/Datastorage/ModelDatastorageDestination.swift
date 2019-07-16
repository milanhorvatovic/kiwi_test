//
//  ModelDatastorageDestination.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Datastorage {
    
    internal struct Destination: Codable {
        
        internal let city: Model.Datastorage.City
        internal let destination: [Model.Service.Destination]
        
        internal let currency: String
        
        internal let date: Date
        
        internal init(
            city: Model.Datastorage.City
            , destination: [Model.Service.Destination]
            , currency: String
            , date: Date = .init()
            )
        {
            self.city = city
            self.destination = destination
            self.currency = currency
            self.date = date
        }
        
    }
    
}
