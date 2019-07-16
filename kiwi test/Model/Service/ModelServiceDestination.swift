//
//  ModelServiceDestination.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Model.Service {
    
    internal struct Destination: Codable {
        
        internal let identifier: String
        
        internal let price: Double
        
        internal let cityFrom: String
        internal let cityTo: String
        
        internal let distance: Double
        
        internal let arrivalTime: TimeInterval
        internal let departureTime: TimeInterval
        
        internal let durationFlight: String
        internal let durationTotal: Int
        
        internal let route: [Route]
        
        private enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case price
            case cityFrom
            case cityTo
            case distance
            case arrivalTime = "aTimeUTC"
            case departureTime = "dTimeUTC"
            case durationFlight = "fly_duration"
            case duration = "duration"
            case durationTotal = "total"
            case route
            
        }
        
        internal init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.identifier = try container.decode(String.self, forKey: .identifier)
            self.price = try container.decode(Double.self, forKey: .price)
            self.cityFrom = try container.decode(String.self, forKey: .cityFrom)
            self.cityTo = try container.decode(String.self, forKey: .cityTo)
            self.distance = try container.decode(Double.self, forKey: .distance)
            self.arrivalTime = try container.decode(TimeInterval.self, forKey: .arrivalTime)
            self.departureTime = try container.decode(TimeInterval.self, forKey: .departureTime)
            self.durationFlight = try container.decode(String.self, forKey: .durationFlight)
            let duration: KeyedDecodingContainer<CodingKeys> = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .duration)
            self.durationTotal = try duration.decode(Int.self, forKey: .durationTotal)
            self.route = try container.decode([Route].self, forKey: .route)
        }
        
        internal func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: .identifier)
            try container.encode(self.price, forKey: .price)
            try container.encode(self.cityFrom, forKey: .cityFrom)
            try container.encode(self.cityTo, forKey: .cityTo)
            try container.encode(self.distance, forKey: .distance)
            try container.encode(self.arrivalTime, forKey: .arrivalTime)
            try container.encode(self.departureTime, forKey: .departureTime)
            try container.encode(self.durationFlight, forKey: .durationFlight)
            var duration: KeyedEncodingContainer<CodingKeys> = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .duration)
            try duration.encode(self.durationTotal, forKey: .durationTotal)
            try container.encode(self.route, forKey: .route)
        }
        
    }
    
}


extension Model.Service.Destination {
    
    internal struct Route: Codable {
        
        internal let identifier: String
        
        internal let cityFrom: String
        internal let cityTo: String
        
        internal let flyFrom: String
        internal let flyTo: String
        
        internal let arrivalTime: TimeInterval
        internal let departureTime: TimeInterval
        
        private enum CodingKeys: String, CodingKey {
            
            case identifier = "id"
            case cityFrom
            case cityTo
            case flyFrom
            case flyTo
            case arrivalTime = "aTimeUTC"
            case departureTime = "dTimeUTC"
            
        }
        
    }
    
}
