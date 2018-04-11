//
//  SearchViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON
import SVProgressHUD
import Firebase

class SearchViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var searchBarView: UIView!
    private let searchBarViewHeight: CGFloat = 45.0
    var placeData: Placeable?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var randomBtn: UIButton! {
        didSet {
            randomBtn.addRoundedCorners(radius: 14)
            randomBtn.addBorder()
        }
    }

    @IBAction func randomBtnTapped(_ sender: Any) {
        logEvent(contentType: "random button tapped")
        guard let randomCity = getRandomCity() else { return }

        SVProgressHUD.show()
        NetworkService().getPlaceId(with: randomCity, success: { [weak self] place in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else { return }

            strongSelf.placeData = place
            strongSelf.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
        }, failure: { [weak self] error in
            SVProgressHUD.dismiss()
            self?.logErrorEvent(error)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        addSearchController()
        fadeInTitleAndButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fadeInTitleAndButton()
        let yCoordinate = view.bounds.height
        searchBarView.frame.origin.y = (yCoordinate / 2) - (searchBarViewHeight / 2)
        searchController?.searchBar.text = ""
    }

    private func fadeInTitleAndButton() {
        titleLabel.alpha = 0
        randomBtn.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseInOut, animations: {
            self.titleLabel.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.8, delay: 1.3, options: .curveEaseInOut, animations: {
            self.randomBtn.alpha = 1
        }, completion: nil)
    }

    private func addSearchController() {
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.setStyle()
        searchController?.delegate = self

        // filter autocomplete results by only showing cities and set styling
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .city
        resultsViewController?.autocompleteFilter = autocompleteFilter
        resultsViewController?.setStyle()

        let yCoordinate = view.bounds.height
        let frame = CGRect(x: 0, y: (yCoordinate / 2) - (searchBarViewHeight / 2), width: view.bounds.width, height: searchBarViewHeight)
        searchBarView = UIView(frame: frame)
        searchBarView.alpha = 0
        searchBarView.addSubview((searchController?.searchBar)!)
        view.addSubview(searchBarView)
        searchController?.searchBar.sizeToFit()

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseInOut, animations: {
            self.searchBarView.alpha = 1
        }, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SearchDetailViewController {
            destinationVC.placeData = placeData
        }
    }
}

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    // Handle the user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        logSearchEvent(searchTerm: searchController?.searchBar.text ?? "Couldn't get search bar text", placeId: place.placeID)
        placeData = place
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
        })
    }

    // Handle the error
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        logErrorEvent(error)
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
            self.titleLabel.alpha = 0
        })
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: {
            let yCoordinate = self.view.bounds.height
            self.searchBarView.frame.origin.y = (yCoordinate / 2) - (self.searchBarViewHeight / 2)
            self.titleLabel.alpha = 1
        })
    }
}

extension SearchViewController: RandomCitySelectable {}
