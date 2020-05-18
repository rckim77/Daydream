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
import Hero

class SearchDetailViewController: UIViewController {

    var dataSource: SearchDetailDataSource?
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var resultView: UITextView?
    private var mapView: GMSMapView?
    private lazy var visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = placeImageView.bounds
        return visualEffectView
    }()
    private let networkService = NetworkService()

    // Constants
    private var searchBarYOffset: CGFloat { // sets search bar's Y offset (not for transition)
        return deviceSize == .iPhoneSE || deviceSize == .iPhone8 ? 100 : 120
    }
    private let searchBarOffset: CGFloat = 12 + 45 // bottom offset + height (used as transition range)
    private let headerContentInset: CGFloat = 142
    private var headerFadeInStartPoint: CGFloat {
        return 142 + notchHeight
    }
    private var headerFadeInEndPoint: CGFloat {
        return 85 + notchHeight
    }
    private let headerFadeOutStartPoint: CGFloat = 100
    private let headerFadeOutEndPoint: CGFloat = 80
    private let floatingTitleViewFadeInStartPoint: CGFloat = 85
    private let floatingTitleViewFadeInEndPoint: CGFloat = 65

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeCardsTableView: UITableView!
    @IBOutlet weak var randomCityButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var floatingTitleView: DesignableView!
    @IBOutlet weak var floatingTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAutocompleteVC()
        configureTableView()
        configureFloatingTitleLabel()
        addSearchController()
        loadDataSource()
    }

    // MARK: - IBActions
    @IBAction func homeBtnTapped(_ sender: UIButton) {
        logEvent(contentType: "home button tapped", title)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func randomCityBtnTapped(_ sender: UIButton) {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity() else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        networkService.getPlaceId(with: randomCity, success: { [weak self] place in
            loadingVC.remove()
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return

            }
            dataSource.place = place
            strongSelf.loadDataSource(reloadMapCard: true)
        }, failure: { [weak self] error in
            loadingVC.remove()
            guard let strongSelf = self else {
                return

            }
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

        let searchBarWidth = view.bounds.width
        let subView = UIView(frame: CGRect(x: 0, y: searchBarYOffset, width: searchBarWidth, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    private func loadDataSource(reloadMapCard: Bool = false) {
        guard let dataSource = dataSource else {
            return
        }

        titleLabel.text = dataSource.place.placeableName
        floatingTitleLabel.text = dataSource.place.placeableName

        dataSource.loadPhoto(success: { [weak self] image in
            guard let strongSelf = self else {
                return
            }

            DispatchQueue.main.async {
                strongSelf.placeImageView.subviews.forEach { $0.removeFromSuperview() }
                strongSelf.placeImageView.image = image
                strongSelf.placeImageView.contentMode = .scaleAspectFill
                strongSelf.placeImageView.addSubview(strongSelf.visualEffectView)
            }
        }, failure: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.logErrorEvent(error)
        })

        dataSource.loadSightsAndEateries(success: { [weak self] indexPaths in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.placeCardsTableView.reloadRows(at: indexPaths, with: .fade)
            }
        }, failure: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.logErrorEvent(error)
        })

        if reloadMapCard {
            placeCardsTableView.reloadRows(at: [dataSource.mapCardCellIndexPath], with: .fade)
        }
    }

    private func configureAutocompleteVC() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
    }

    private func configureTableView() {
        placeCardsTableView.dataSource = dataSource
        placeCardsTableView.delegate = self
        placeCardsTableView.tableFooterView = UIView()
        placeCardsTableView.contentInset = UIEdgeInsets(top: headerContentInset, left: 0, bottom: 0, right: 0)
        dataSource?.viewController = self
    }

    private func configureFloatingTitleLabel() {
        floatingTitleView.alpha = 0
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
extension SearchDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataSource = dataSource else {
            return 0
        }

        switch indexPath.row {
        case 0:
            return dataSource.mapCardCellHeight
        default:
            return dataSource.sightsCardCellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else {
            return
        }

        if indexPath.row == 0 {
            logEvent(contentType: "select map card cell", title)

            if let mapUrl = dataSource.place.placeableMapUrl {
                openUrl(mapUrl)
            } else if let placeId = dataSource.place.placeableId {
                networkService.getPlace(with: placeId, success: { [weak self] place in
                    guard let strongSelf = self, let mapUrl = place.placeableMapUrl else {
                        return
                    }
                    strongSelf.openUrl(mapUrl)
                }, failure: { [weak self] error in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.logErrorEvent(error)
                })
            }
        }
    }

    // MARK: - Scrolling Transition Methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        transitionSearchBar(yOffset)
        transitionHeader(yOffset)
        transitionFloatingTitleLabel(yOffset)
    }

    private func transitionSearchBar(_ yOffset: CGFloat) {
        if yOffset > -headerFadeInStartPoint {
            let calculatedAlpha = (-yOffset - headerFadeInEndPoint) / searchBarOffset
            searchController?.searchBar.alpha = max(calculatedAlpha, 0)
            view.insertSubview(floatingTitleView, aboveSubview: placeCardsTableView)
        } else {
            searchController?.searchBar.alpha = 1
        }
    }

    private func transitionHeader(_ yOffset: CGFloat) {
        if yOffset >= -headerFadeOutStartPoint {
            let calculatedHeaderAlpha = (-yOffset - headerFadeOutEndPoint) / (headerFadeOutStartPoint - headerFadeOutEndPoint)
            view.insertSubview(placeCardsTableView, aboveSubview: randomCityButton)
            titleLabel.alpha = min(calculatedHeaderAlpha, 1)
            randomCityButton.alpha = min(calculatedHeaderAlpha, 1)
            homeButton.alpha = min(calculatedHeaderAlpha, 1)
        } else {
            view.insertSubview(placeCardsTableView, aboveSubview: placeImageView)
            titleLabel.alpha = 1
            randomCityButton.alpha = 1
            homeButton.alpha = 1
        }
    }

    private func transitionFloatingTitleLabel(_ yOffset: CGFloat) {
        if yOffset >= -floatingTitleViewFadeInStartPoint {
            let range = floatingTitleViewFadeInStartPoint - floatingTitleViewFadeInEndPoint
            let calculatedAlpha = 1 - ((-yOffset - floatingTitleViewFadeInEndPoint) / range)
            floatingTitleView.alpha = min(calculatedAlpha, 1)
        } else {
            floatingTitleView.alpha = 0
        }
    }
}

// MARK: - GooglePlaces Autocomplete methods
extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {

    // Handle user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        let searchBarText = searchController?.searchBar.text ?? "Couldn't get search bar text"
        let placeId = place.placeID ?? "Couldn't get place ID"
        logSearchEvent(searchTerm: searchBarText, placeId: placeId)
        searchController?.searchBar.text = nil // reset to search bar text

        dismiss(animated: true, completion: {
            guard let dataSource = self.dataSource else {
                return
            }

            dataSource.place = place
            self.loadDataSource(reloadMapCard: true)
        })
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        logErrorEvent(error)
    }
}

extension SearchDetailViewController: SightsCardCellDelegate {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Placeable) {
        logEvent(contentType: "select point of interest", title)
        performSegue(withIdentifier: "genericMapSegue", sender: place)
    }
}

extension SearchDetailViewController: EateriesCardCellDelegate {
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectEatery eatery: Eatery) {
        logEvent(contentType: "select eatery", title)
        openUrl(eatery.url)
    }
}

extension SearchDetailViewController: RandomCitySelectable, Loggable {}
