//
//  ModelServiceResponse.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    internal enum Response {
        
    }
    
}

extension Model.Service.Response {
    
    internal struct Location: Codable {
        
        internal let locations: [Model.Service.Location]
        
    }
    
}

extension Model.Service.Response {
    
    internal struct Destination: Codable {
        
        internal let destination: [Model.Service.Destination]
        
        internal let currency: String
        
        private enum CodingKeys: String, CodingKey {
            
            case destination = "data"
            case currency
            
        }
        
    }
    
}
