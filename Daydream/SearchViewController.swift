//
//  SearchViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var searchBarView: UIView!
    private let searchBarViewHeight: CGFloat = 45.0
    
    var placeData: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        addSearchController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let yCoordinate = view.bounds.height
        
        searchBarView.frame.origin.y = (yCoordinate / 2) - (searchBarViewHeight / 2)
    }
    
    private func addSearchController() {
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.placeholder = "e.g., Tokyo"
        searchController?.delegate = self
        
        // filter autocomplete results by only showing cities
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .city
        resultsViewController?.autocompleteFilter = autocompleteFilter
        
        let yCoordinate = view.bounds.height
        
        searchBarView = UIView(frame: CGRect(x: 0, y: (yCoordinate / 2) - (searchBarViewHeight / 2), width: view.bounds.width, height: searchBarViewHeight))
        searchBarView.addSubview((searchController?.searchBar)!)
        view.addSubview(searchBarView)
        searchController?.searchBar.sizeToFit()
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SearchDetailViewController {
            // pass data
            destinationVC.placeData = placeData
        }
    }
    
}

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    // Handle the user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
        placeData = place
        
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
        })
    }
    
    // Handle the error
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension SearchViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBarView.frame.origin.y = 65.0
        })
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: {
            let yCoordinate = self.view.bounds.height
            self.searchBarView.frame.origin.y = (yCoordinate / 2) - (self.searchBarViewHeight / 2)
        })
    }
    
}
