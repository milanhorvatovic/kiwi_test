//
//  ModelServiceLocation.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 15/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    internal struct Location: Codable {
        
        internal let identifier: String
        internal let name: String
        internal let code: String
        
        private enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case name
            case code
            
        }
        
    }
    
}

extension Model.Service.Location: Comparable {
    
    internal static func < (lhs: Model.Service.Location, rhs: Model.Service.Location) -> Bool {
        return lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.code == rhs.code
    }
    
}
