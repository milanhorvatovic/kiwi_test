//
//  ServiceManager.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

internal enum Service {
    
    internal class Manager {
        
        struct Endpoint {
            
            let path: String
            let queryItems: [URLQueryItem]
            
        }
        
        internal let session: URLSession
        
        private let delegateQueue: OperationQueue
        
        private var task: [Int: URLSessionTask]
        
        internal init() {
            self.delegateQueue = .init()
            self.delegateQueue.name = (Bundle.main.bundleIdentifier ?? "") + "service.manager.queue.delegate"
            
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            self.session = .init(configuration: configuration, delegate: .none, delegateQueue: self.delegateQueue)
            self.task = [:]
        }
        
        internal func cancel(for taskIdentifier: Int) {
            guard let task: URLSessionTask = self.task[taskIdentifier] else {
                return
            }
            task.cancel()
            self.task.removeValue(forKey: taskIdentifier)
        }
        
        fileprivate func _makeRequest<ResponseType>(at request: URLRequest, closure: @escaping (ResponseType?, Error?) -> ()) -> Int where ResponseType: Decodable {
            var taskIdentifier: Int = 0
            let task: URLSessionDataTask = self.session.dataTask(with: request, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                defer {
                    self?.task.removeValue(forKey: taskIdentifier)
                }
                guard case .none = error else {
                    closure(.none, error)
                    return
                }
                guard let data: Data = data else {
                    closure(.none, .none)
                    return
                }
                
                do {
                    let response: ResponseType = try JSONDecoder().decode(ResponseType.self, from: data)
                    closure(response, .none)
                }
                catch {
                    closure(.none, error)
                }
            })
            taskIdentifier = task.taskIdentifier
            self.task[taskIdentifier] = task
            defer {
                task.resume()
            }
            return task.taskIdentifier
        }
    }
    
}

extension Service.Manager.Endpoint {

    internal var url: URL? {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "api.skypicker.com"
        components.path = self.path
        components.queryItems = self.queryItems
        
        return components.url
    }
    
}

extension Service.Manager {
    
    private static let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    @discardableResult
    internal func get(location: String, closure: @escaping (Model.Service.Response.Location?, Error?) -> Void) -> Int {
        let endpoint: Endpoint = .init(
            path: "/locations",
            queryItems: [
                URLQueryItem(name: "location_types", value: "city")
                , URLQueryItem(name: "limit", value: "25")
                , URLQueryItem(name: "active_only", value: "true")
                , URLQueryItem(name: "sort", value: "name")
                , URLQueryItem(name: "term", value: location)
            ]
        )
        let request: URLRequest = .init(url: endpoint.url!)
        return self._makeRequest(at: request, closure: closure)
    }
    
    @discardableResult
    internal func search(location: String, from: Date, to: Date, closure: @escaping (Model.Service.Response.Destination?, Error?) -> Void) -> Int {
        let endpoint: Endpoint = .init(
            path: "/flights",
            queryItems: [
                URLQueryItem(name: "v", value: "2")
                , URLQueryItem(name: "sort", value: "popularity")
                , URLQueryItem(name: "asc", value: "0")
                , URLQueryItem(name: "limit", value: "5")
                , URLQueryItem(name: "typeFlight", value: "oneway")
                , URLQueryItem(name: "dateFrom", value: type(of: self).dateFormatter.string(from: from))
                , URLQueryItem(name: "dateTo", value: type(of: self).dateFormatter.string(from: to))
                , URLQueryItem(name: "fly_from", value: location)
            ]
        )
        let request: URLRequest = .init(url: endpoint.url!)
        return self._makeRequest(at: request, closure: closure)
    }
    
}
