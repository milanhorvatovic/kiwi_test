//
//  DestinationDatastorageProvider.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal final class DestinationDatastorageProvider {
    
    private enum Consts {
        
        fileprivate enum Keys {
            
            fileprivate static let userDefault: String = "Destination"
            
            fileprivate static let city: String = "city"
            fileprivate static let destination: String = "destination"
            
        }
        
    }
    
    private let _lock: NSLock = {
        return .init()
    }()
    
    private let storage: UserDefaults = {
        guard let storage: UserDefaults = UserDefaults(suiteName: Consts.Keys.userDefault) else {
            fatalError("Storage couldn't be initiated")
        }
        return storage
    }()
    
    func fetchCity() throws -> Model.Datastorage.City? {
        self._lock.lock()
        defer {
            self._lock.unlock()
        }
        guard let data: Data = self.storage.object(forKey: Consts.Keys.city) as? Data else {
            return .none
        }
        return try JSONDecoder().decode(Model.Datastorage.City.self, from: data)
    }
    
    func store(city value: Model.Datastorage.City) throws {
        self._lock.lock()
        defer {
            self._lock.unlock()
        }
        self.storage.set(try JSONEncoder().encode(value), forKey: Consts.Keys.city)
    }
    
    func fetchDestination() throws -> Model.Datastorage.Destination? {
        self._lock.lock()
        defer {
            self._lock.unlock()
        }
        guard let data: Data = self.storage.object(forKey: Consts.Keys.destination) as? Data else {
            return .none
        }
        return try JSONDecoder().decode(Model.Datastorage.Destination.self, from: data)
    }
    
    func store(destination value: Model.Datastorage.Destination) throws {
        self._lock.lock()
        defer {
            self._lock.unlock()
        }
        self.storage.set(try JSONEncoder().encode(value), forKey: Consts.Keys.destination)
    }
    
}
