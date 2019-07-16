//
//  ViewController.swift
//  kiwi test
//
//  Created by Milan Horvatovic on 15/07/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

internal final class ViewController: UIViewController {

    @IBOutlet private weak var departureButton: UIButton!
    @IBOutlet private weak var departureLabel: UILabel!
    @IBOutlet private weak var overlay: UIView!
    @IBOutlet private weak var noContentLabel: UILabel!
    @IBOutlet private weak var pageViewContainer: UIView!
    @IBOutlet private weak var pageViewController: UIPageViewController! {
        didSet {
            self.pageViewController.delegate = self
            self.pageViewController.dataSource = self
        }
    }
    @IBOutlet private weak var pageControl: UIPageControl!
    
    internal var dataProvider: DataProvider?
    
    internal var departure: Model.Service.Location? {
        didSet {
            self.update(city: self.departure)
            self.reloadDestination(departure: self.departure)
        }
    }
    internal var data: Model.Datastorage.Destination? {
        didSet {
            self.update(destination: self.data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.dataProvider?.fetchDestination({ [weak self] (data: Model.Datastorage.Destination?, error: Error?) in
            guard case .none = error else {
                return
            }
            guard let data: Model.Datastorage.Destination = data else {
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.departure = .none
                    self?.data = .none
                })
                return
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                self?.data = data
                self?.departure = data.city.from
            })
            
        })
    }
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "PagesSegueIdentifier":
            self.pageViewController = (segue.destination as? UIPageViewController)
        case "DepartureSegueIdentifier":
            ((segue.destination as? UINavigationController)?.viewControllers.first as? LocationViewController)?.dataProvider = self.dataProvider
            ((segue.destination as? UINavigationController)?.viewControllers.first as? LocationViewController)?.title = "Locating departure:"
            ((segue.destination as? UINavigationController)?.viewControllers.first as? LocationViewController)?.selectionClosure = { [weak self] (data: Model.Service.Location) in
                self?.departure = data
            }
        default:
            break
        }
    }
    
    private func update(city departure: Model.Service.Location?) {
        switch departure?.name {
        case .some(let value):
            self.departureButton.setTitle("Exchange", for: .normal)
            self.departureLabel.text = value
        case .none:
            self.departureButton.setTitle("Set", for: .normal)
            self.departureLabel.text = .none
        }
    }
    
    private func update(destination: Model.Datastorage.Destination?) {
        guard let destination: Model.Datastorage.Destination = destination else {
            UIView.animate(
                withDuration: 0.25
                , animations: { [weak self] in
                    self?.noContentLabel.alpha = 1.0
                    self?.pageViewContainer.alpha = 0.0
                }
            )
            return
        }
        
        UIView.animate(
            withDuration: 0.25
            , animations: { [weak self] in
                self?.noContentLabel.alpha = 0.0
                self?.pageViewContainer.alpha = 1.0
                
            }
        )
        
        guard let viewController: DestinationPageViewController = self.pageViewController(self.pageViewController, viewControllerAt: 0) as? DestinationPageViewController else {
            return
        }
        self.pageViewController.setViewControllers([viewController], direction: .forward, animated: false, completion: .none)
        self.pageControl.numberOfPages = destination.destination.count
        self.pageControl.currentPage = 0
    }
    
    private func reloadDestination(departure: Model.Service.Location?) {
        guard let departure: Model.Service.Location = departure else {
            return
        }
        
        if let data: Model.Datastorage.Destination = self.data
            , data.city.from == departure
        {
            return
        }
        
        UIView.animate(
            withDuration: 0.25
            , animations: { [weak self] in
                self?.overlay.alpha = 1.0
            }
        )
        self.dataProvider?.findDestination(
            location: departure.code
            , from: .init()
            , { [weak self] (data: Model.Service.Response.Destination?, error: Error?) in
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
                        guard let selfStrong = self else {
                            return
                        }
                        let alertController: UIAlertController = .init(title: "Error", message: error?.localizedDescription ?? "", preferredStyle: .alert)
                        alertController.addAction(
                            .init(
                                title: "OK"
                                , style: .cancel
                                , handler: { [weak alertController] (action: UIAlertAction) in
                                    alertController?.dismiss(animated: true, completion: .none)
                                }
                            )
                        )
                        selfStrong.present(alertController, animated: true, completion: .none)
                    })
                    return
                }
                guard let data: Model.Service.Response.Destination = data else {
                    return
                }
                
                do {
                    let data: Model.Datastorage.Destination = .init(city: .init(from: departure), destination: data.destination)
                    try self?.dataProvider?.store(destination: data)
                    DispatchQueue.main.async(execute: { [weak self] in
                        self?.data = data
                    })
                }
                catch {
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let selfStrong = self else {
                            return
                        }
                        let alertController: UIAlertController = .init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(
                            .init(
                                title: "OK"
                                , style: .cancel
                                , handler: { [weak alertController] (action: UIAlertAction) in
                                    alertController?.dismiss(animated: true, completion: .none)
                                }
                            )
                        )
                        selfStrong.present(alertController, animated: true, completion: .none)
                    })
                }
            }
        )
    }
    
}

extension ViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController: DestinationPageViewController = pageViewController.viewControllers?.first as? DestinationPageViewController else {
            return
        }
        self.pageControl.currentPage = viewController.index
    }
    
}

extension ViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.data?.destination.count ?? 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController: DestinationPageViewController = viewController as? DestinationPageViewController else {
            return .none
        }
        let index: Int = viewController.index
        
        guard index > 0 else {
            return .none
        }
        
        return self.pageViewController(pageViewController, viewControllerAt: UInt(index - 1))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController: DestinationPageViewController = viewController as? DestinationPageViewController else {
            return .none
        }
        let index: Int = viewController.index + 1
        guard index < self.presentationCount(for: pageViewController) else {
            return .none
        }
        return self.pageViewController(pageViewController, viewControllerAt: UInt(index))
    }
    
    private func pageViewController(_ pageViewController: UIPageViewController, viewControllerAt index: UInt) -> UIViewController? {
        guard index < self.presentationCount(for: pageViewController) else {
            return .none
        }
        let index: Int = Int(index)
        let viewController: DestinationPageViewController = self.storyboard!.instantiateViewController(withIdentifier: "DestinationPageViewControllerIdentifier") as! DestinationPageViewController
        viewController.index = index
        viewController.data = self.data?.destination[index]
        //viewController.view.backgroundColor = .init(red: CGFloat.random(in: 1 ..< 255) / 255, green: CGFloat.random(in: 1 ..< 255) / 255, blue: CGFloat.random(in: 1 ..< 255) / 255, alpha: 1.0)
        return viewController
    }
    
}
