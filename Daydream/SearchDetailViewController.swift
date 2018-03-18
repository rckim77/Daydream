//
//  SearchDetailViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import GoogleMaps
import Alamofire
import SwiftyJSON

class SearchDetailViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var mapView: GMSMapView?
    var placeData: GMSPlace?
    var pointsOfInterest: [PointOfInterest]?
    var eateries: [Eatery]?
    private let mapCardCellHeight: CGFloat = 190
    private let sightsCardCellHeight: CGFloat = 570
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeCardsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAutocompleteVC()
        configureTableView()
        addSearchController()
        loadContent(for: placeData)
    }

    // MARK: - IBActions
    @IBAction func homeBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Search
    private func addSearchController() {

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.setStyle()

        // filter autocomplete results by only showing cities and set styling
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .city
        resultsViewController?.autocompleteFilter = autocompleteFilter
        resultsViewController?.setStyle()

        let subView = UIView(frame: CGRect(x: 0, y: 128.0, width: view.bounds.width, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    private func loadContent(for place: GMSPlace?) {
        if let place = place {
            titleLabel.text = place.name

            loadPhotoForPlace(placeId: place.placeID, completion: { [weak self] photo in
                guard let strongSelf = self else { return }
                strongSelf.placeImageView.image = photo
                strongSelf.placeImageView.contentMode = .scaleAspectFill

                // add a blur for now since resolution isn't great
                let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
                visualEffectView.frame = strongSelf.placeImageView.bounds
                strongSelf.placeImageView.addSubview(visualEffectView)
            })

            let networkService = NetworkService()

            networkService.loadTopSights(with: place, success: { [weak self] pointsOfInterest in
                guard let strongSelf = self else { return }
                strongSelf.pointsOfInterest = pointsOfInterest
                strongSelf.placeCardsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                }, failure: { error in
                    print(error)
            })

            networkService.loadTopEateries(with: place, success: { [weak self] eateries in
                guard let strongSelf = self else { return }
                strongSelf.eateries = eateries
                strongSelf.placeCardsTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                }, failure: { error in
                    print(error)
            })
        } else {
            // TODO: show default background screen
        }
    }

    private func presentPlacePicker(with viewport: GMSCoordinateBounds) {
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self

        present(placePicker, animated: true, completion: nil)
    }

    private func configureAutocompleteVC() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
    }

    private func configureTableView() {
        placeCardsTableView.dataSource = self
        placeCardsTableView.delegate = self
        placeCardsTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView datasource and delegate methods
extension SearchDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? mapCardCellHeight : sightsCardCellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath)

            if let mapCardCell = cell as? MapCardCell {

                mapCardCell.place = placeData

                return mapCardCell
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sightsCardCell", for: indexPath)

            if let sightsCardCell = cell as? SightsCardCell {

                sightsCardCell.delegate = self
                sightsCardCell.pointsOfInterest = pointsOfInterest

                return sightsCardCell
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eateriesCardCell", for: indexPath)

            if let eateriesCardCell = cell as? EateriesCardCell {

                eateriesCardCell.delegate = self
                eateriesCardCell.eateries = eateries

                return eateriesCardCell
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // for viewport, enter GMSCoordinateBounds object
            guard let viewport = placeData?.viewport else { return }

            let config = GMSPlacePickerConfig(viewport: viewport)
            let placePicker = GMSPlacePickerViewController(config: config)
            placePicker.delegate = self

            present(placePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - GooglePlaces Autocomplete methods
extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {

    // Handle user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {

        searchController?.searchBar.text = nil // reset to search bar text

        dismiss(animated: true, completion: {
            self.placeData = place
            self.loadContent(for: place)
        })
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        print("Autocomplete Error: ", error.localizedDescription)
    }

    // Turn the network activity indicator on and off again
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - GooglePlacePicker methods
extension SearchDetailViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//        viewController.dismiss(animated: true, completion: nil)
        // TODO: zoom into that place and show more info

        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
    }

    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

}

extension SearchDetailViewController: SightsCardCellDelegate {
    func didSelectPointOfInterest(with viewport: GMSCoordinateBounds) {
        presentPlacePicker(with: viewport)
    }
}

extension SearchDetailViewController: EateriesCardCellDelegate {
    func didSelectEatery(_ eatery: Eatery) {
        if let url = URL(string: eatery.url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
