//
//  DataProvider.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal class DataProvider {
    
    internal let service: Service.Manager
    internal let datastorage: DestinationDatastorageProvider
    
    private var findCityIdentificator: Int?
    private var findDestinationIdentificator: Int?
    
    internal init(
        service: Service.Manager
        , datastorage: DestinationDatastorageProvider
        )
    {
        self.service = service
        self.datastorage = datastorage
    }
    
    //  MARK: City
    internal func fetchCity(_ closure: @escaping (Model.Datastorage.City?, Error?) -> Void) {
        do {
            closure(try self.datastorage.fetchCity(), .none)
        }
        catch {
            closure(.none, error)
        }
    }
    
    internal func store(city value: Model.Datastorage.City) throws {
        try self.datastorage.store(city: value)
    }
    
    internal func findCity(with term: String, _ closure: @escaping (Model.Service.Response.Location?, Error?) -> Void) {
        if let value: Int = self.findCityIdentificator {
            self.service.cancel(for: value)
        }
        self.findCityIdentificator = self.service.get(
            location: term
            , closure: { [weak self] (data: Model.Service.Response.Location?, error: Error?) in
                self?.findCityIdentificator = .none
                closure(data, error)
            }
        )
    }
    
    //  MARK: Destination
    internal func fetchDestination(_ closure: @escaping (Model.Datastorage.Destination?, Error?) -> Void) {
        do {
            guard let value: Model.Datastorage.Destination = try self.datastorage.fetchDestination() else {
                closure(.none, .none)
                return
            }
            guard Date().timeIntervalSince(value.date) > 60 * 60 * 24 else {
                closure(value, .none)
                return
            }
            self.findDestination(
                location: value.city.from.code
                , destination: value.city.to.code
                , from: .init()
                , { [weak self] (data: Model.Service.Response.Destination?, error: Error?) in
                    guard let data: Model.Service.Response.Destination = data else {
                        closure(.none, error)
                        return
                    }
                    
                    let destination: Model.Datastorage.Destination = .init(city: value.city, destination: data.destination)
                    do {
                        try self?.datastorage.store(destination: destination)
                        closure(destination, .none)
                    }
                    catch {
                        closure(.none, error)
                    }
                }
            )
        }
        catch {
            closure(.none, error)
        }
    }
    
    internal func store(destination value: Model.Datastorage.Destination) throws {
        try self.datastorage.store(destination: value)
    }
    
    internal func findDestination(location: String, destination: String, from: Date, _ closure: @escaping (Model.Service.Response.Destination?, Error?) -> Void) {
        if let value: Int = self.findDestinationIdentificator {
            self.service.cancel(for: value)
        }
        guard let to: Date = Calendar.current.date(byAdding: .day, value: 1, to: from) else {
            closure(.none, .none)
            return
        }
        self.findDestinationIdentificator = self.service.search(
            location: location
            , destination: destination
            , from: from
            , to: to
            , closure: { [weak self] (data: Model.Service.Response.Destination?, error: Error?) in
                self?.findDestinationIdentificator = .none
                closure(data, error)
            }
        )
    }
    
}
