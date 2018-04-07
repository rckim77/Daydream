//
//  SearchDetailViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import Hero
import SVProgressHUD
import Firebase

class SearchDetailViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var mapView: GMSMapView?
    var placeData: Placeable?
    var pointsOfInterest: [Placeable]?
    var eateries: [Eatery]?
    private var visualEffectView: UIVisualEffectView {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = placeImageView.bounds
        return visualEffectView
    }
    private let networkService = NetworkService()
    private let summaryCardCellHeight: CGFloat = 190
    private let mapCardCellHeight: CGFloat = 190
    private let mapCardCellIndexPath = IndexPath(row: 0, section: 0)
    private let sightsCardCellHeight: CGFloat = 600
    private let sightsCardCellIndexPath = IndexPath(row: 1, section: 0)
    private let eateriesCardCellIndexPath = IndexPath(row: 2, section: 0)
    
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
        logEvent(contentType: "home button tapped")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func randomCityBtnTapped(_ sender: UIButton) {
        logEvent(contentType: "random button tapped")
        guard let randomCity = getRandomCity() else { return }
        SVProgressHUD.show()
        
        NetworkService().getPlaceId(with: randomCity, success: { [weak self] place in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else { return }

            strongSelf.placeData = place
            strongSelf.loadContent(for: place, reloadMapCard: true)
        }, failure: { [weak self] error in
            SVProgressHUD.dismiss()
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })
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

    private func loadContent(for place: Placeable?, reloadMapCard: Bool = false) {
        guard let place = place else { return }

        titleLabel.text = place.placeableName

        networkService.loadPhoto(with: place.placeableId, success: { [weak self] photo in
            guard let strongSelf = self else { return }
            strongSelf.placeImageView.subviews.forEach { $0.removeFromSuperview() }
            strongSelf.placeImageView.image = photo
            strongSelf.placeImageView.contentMode = .scaleAspectFill    
            strongSelf.placeImageView.addSubview(strongSelf.visualEffectView)

        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })

        networkService.loadTopSights(with: place, success: { [weak self] pointsOfInterest in
            guard let strongSelf = self else { return }
            strongSelf.pointsOfInterest = pointsOfInterest
            strongSelf.placeCardsTableView.reloadRows(at: [strongSelf.sightsCardCellIndexPath], with: .fade)
        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })

        networkService.loadTopEateries(with: place, success: { [weak self] eateries in
            guard let strongSelf = self else { return }
            strongSelf.eateries = eateries
            strongSelf.placeCardsTableView.reloadRows(at: [strongSelf.eateriesCardCellIndexPath], with: .fade)
        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })

        if reloadMapCard {
            placeCardsTableView.reloadRows(at: [mapCardCellIndexPath], with: .fade)
        }
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

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? MapViewController, let sender = sender as? Placeable {
            // segue from Top Sights cell
            if segue.identifier == "genericMapSegue" {
                destinationVC.place = sender
                destinationVC.heroId = "pointOfInterestCard"
            }
        }
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
        switch indexPath.row {
        case 0:
            return mapCardCellHeight
        default:
            return sightsCardCellHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case mapCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath)

            if let mapCardCell = cell as? MapCardCell {
                mapCardCell.place = placeData

                return mapCardCell
            }
            return cell
        case sightsCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sightsCardCell", for: indexPath)

            if let sightsCardCell = cell as? SightsCardCell {
                sightsCardCell.delegate = self
                sightsCardCell.pointsOfInterest = pointsOfInterest

                return sightsCardCell
            }
            return cell
        case eateriesCardCellIndexPath:
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
            logEvent(contentType: "select map card cell")
            guard let place = placeData else { return }

            if let mapUrl = place.placeableMapUrl {
                openUrl(mapUrl)
            } else {
                networkService.getPlace(with: place.placeableId, success: { [weak self] place in
                    guard let strongSelf = self, let mapUrl = place.placeableMapUrl else { return }
                    strongSelf.openUrl(mapUrl)
                }, failure: { [weak self] error in
                    guard let strongSelf = self else { return }
                    strongSelf.logErrorEvent(error)
                })
            }
        }
    }
}

// MARK: - GooglePlaces Autocomplete methods
extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {

    // Handle user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        logSearchEvent(searchTerm: searchController?.searchBar.text ?? "Couldn't get search bar text", placeId: place.placeID)
        searchController?.searchBar.text = nil // reset to search bar text

        dismiss(animated: true, completion: {
            self.placeData = place
            self.loadContent(for: place, reloadMapCard: true)
        })
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        logErrorEvent(error)
    }

    // Turn the network activity indicator on and off again
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension SearchDetailViewController: SightsCardCellDelegate {
    func didSelectPointOfInterest(with place: Placeable) {
        logEvent(contentType: "select point of interest")
        performSegue(withIdentifier: "genericMapSegue", sender: place)
    }
}

extension SearchDetailViewController: EateriesCardCellDelegate {
    func didSelectEatery(_ eatery: Eatery) {
        logEvent(contentType: "select eatery")
        openUrl(eatery.url)
    }
}

extension SearchDetailViewController: RandomCitySelectable {}
