//
//  DebouncedSearchBar.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 16/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

import UIKit

internal final class DebouncedSearchBar: UISearchBar, UISearchBarDelegate {
    
    // MARK: - Properties
    
    /// Debounce engine
    private var debouncer: Debouncer?
    
    /// Debounce interval
    var debounceInterval: TimeInterval = 0 {
        didSet {
            guard debounceInterval > 0 else {
                self.debouncer = nil
                return
            }
            self.debouncer = Debouncer(seconds: debounceInterval)
        }
    }
    
    /// Event received when the search textField began editing
    var onSearchTextDidBeginEditing: (() -> Void)?
    
    /// Event received when the search textField content changes
    var onSearchTextUpdate: ((String) -> Void)?
    
    /// Event received when the search button is clicked
    var onSearchClicked: (() -> Void)?
    
    /// Event received when cancel is pressed
    var onCancel: (() -> Void)?
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        onCancel?()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchClicked?()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        onSearchTextDidBeginEditing?()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let debouncer = self.debouncer else {
            onSearchTextUpdate?(searchText)
            return
        }
        debouncer.debounce {
            DispatchQueue.main.async {
                self.onSearchTextUpdate?(self.text ?? "")
            }
        }
    }
    
}
