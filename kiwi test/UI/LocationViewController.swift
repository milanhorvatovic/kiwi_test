//
//  LocationViewController.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation
import UIKit

internal final class LocationViewController: UIViewController {
    
    fileprivate let cellIdentifier: String = {
        return "\(type(of: self))"
    }()
    
    internal var dataProvider: DataProvider?
    
    internal private(set) var data: [Model.Service.Location] = []
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: DebouncedSearchBar!
    @IBOutlet private weak var overlay: UIView!
    
    internal var selectionClosure: ((Model.Service.Location) -> ())?
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = self.searchBar
        
        self.searchBar.debounceInterval = 0.25
        self.searchBar.onSearchTextUpdate = { [weak self] (searchText: String) in
            guard case false = searchText.isEmpty else {
                self?.data.removeAll()
                self?.tableView.reloadData()
                return
            }
            
            UIView.animate(
                withDuration: 0.25
                , animations: { [weak self] in
                    self?.overlay.alpha = 1.0
                }
            )
            self?.dataProvider?.findCity(
                with: searchText
                , { [weak self] (data: Model.Service.Response.Location?, error: Error?) in
                    defer {
                        DispatchQueue.main.async(execute: { [weak self] in
                            UIView.animate(
                                withDuration: 0.25
                                , animations: { [weak self] in
                                    self?.overlay.alpha = 0.0
                                }
                            )
                        })
                    }
                    guard case .none = error else {
                        DispatchQueue.main.async(execute: { [weak self] in
                            self?.data.removeAll()
                            self?.tableView.reloadData()
                        })
                        return
                    }
                    guard let data: Model.Service.Response.Location = data else {
                        DispatchQueue.main.async(execute: { [weak self] in
                            self?.data.removeAll()
                            self?.tableView.reloadData()
                        })
                        return
                    }
                    DispatchQueue.main.async(execute: { [weak self] in
                        self?.data = data.locations
                        self?.tableView.reloadData()
                    })
            })
        }
    }
    
    @IBAction
    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: .none)
    }
    
}

extension LocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: Model.Service.Location = self.data[indexPath.row]
        self.selectionClosure?(data)
        self.dismiss()
    }
    
}

extension LocationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier)
        if case .none = cell {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellIdentifier)
        }
        
        let data: Model.Service.Location = self.data[indexPath.row]
        cell.textLabel?.text = data.name
        return cell
    }
    
}
