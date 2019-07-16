//
//  DestinationPageViewController.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

internal final class DestinationPageViewController: UIViewController {
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    fileprivate static let currencyFormatter: NumberFormatter = {
        let formatter: NumberFormatter = .init()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.numberStyle = .currencyAccounting
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var stopsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var flightDuration: UILabel!
    
    internal var index: Int = -1
    
    internal var data: Model.Service.Destination? {
        didSet {
            guard let data: Model.Service.Destination = self.data else {
                return
            }
            self.update(from: data)
        }
    }
    internal var currencyCode: String? {
        didSet {
            if let currencyCode: String = self.currencyCode {
                type(of: self).currencyFormatter.currencyCode = currencyCode
            }
        }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data: Model.Service.Destination = self.data else {
            return
        }
        self.update(from: data)
    }
    
    private func update(from data: Model.Service.Destination) {
        guard case true = self.isViewLoaded else {
            return
        }
        self.fromLabel.text = "From: \(data.cityFrom)"
        self.destinationLabel.text = "To: \(data.cityTo)"
        self.priceLabel.text = type(of: self).currencyFormatter.string(for: data.price)
        
        switch data.route.count {
        case 0:
            self.stopsLabel.text = "Unknonwn number of steps"
        case 1:
            self.stopsLabel.text = "Direct flight, destination reachable without stops"
        default:
            let stops: [String] = data.route
                .sorted(by: { (lhs: Model.Service.Destination.Route, rhs: Model.Service.Destination.Route) -> Bool in
                    return lhs.arrivalTime < rhs.arrivalTime
                })
                .map({ (object: Model.Service.Destination.Route) -> String in
                    return object.cityTo
                })
                .filter({ (value: String) -> Bool in
                    return value != data.cityTo
                })
            self.stopsLabel.text = "\(stops.count) stops: \(stops.joined(separator: ", "))"
        }
        
        self.departureLabel.text = "Departure: \n\(type(of: self).dateFormatter.string(from: Date(timeIntervalSince1970: data.departureTime)))"
        self.arrivalLabel.text = "Arrival: \n\(type(of: self).dateFormatter.string(from: Date(timeIntervalSince1970: data.arrivalTime)))"
        self.distanceLabel.text = "\(data.distance) km"
        self.flightDuration.text = data.durationFlight
    }
    
}
