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
import SnapKit

class SearchDetailViewController: UIViewController {

    var dataSource: SearchDetailDataSource?
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var resultView: UITextView?
    private var mapView: GMSMapView?

    private lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        return label
    }()

    private lazy var randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "diceCubeHardShadow"), for: .normal)
        return button
    }()

    private lazy var homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "homeWhiteShadow"), for: .normal)
        return button
    }()

    private lazy var visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = placeImageView.bounds
        return visualEffectView
    }()

    private let networkService = NetworkService()
    private let headerSectionHeight: CGFloat = 100
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeCardsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureHeaderSection()
        loadDataSource()
    }

    // MARK: - IBActions
    @IBAction func homeBtnTapped(_ sender: UIButton) {
        logEvent(contentType: "home button tapped", title)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func randomCityBtnTapped(_ sender: UIButton) {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity() else { return }
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        networkService.getPlaceId(with: randomCity, success: { [weak self] place in
            loadingVC.remove()
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else { return }
            dataSource.place = place
            strongSelf.loadDataSource(reloadMapCard: true)
        }, failure: { [weak self] error in
            loadingVC.remove()
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })
    }

    // MARK: - UI Configuration methods

    private func configureHeaderSection() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(randomButton)
        headerView.addSubview(homeButton)

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }

        randomButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.height.width.equalTo(24)
            make.top.equalToSuperview().inset(16)
        }

        homeButton.snp.makeConstraints { make in
            make.leading.equalTo(randomButton.snp.trailing).offset(4)
            make.height.width.equalTo(24)
            make.top.equalTo(16)
            make.trailing.equalToSuperview().inset(16)
        }

        configureSearchController()
        configureResultsVC()
    }

    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.setStyle()

        //        let subView = UIView(frame: CGRect(x: 0, y: 128.0, width: view.bounds.width, height: 45.0))
        //        subView.addSubview((searchController?.searchBar)!)
        //        view.addSubview(subView)
        //        searchController?.searchBar.sizeToFit()

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    private func configureResultsVC() {
        // filter autocomplete results by only showing cities and set styling
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .city
        resultsViewController?.autocompleteFilter = autocompleteFilter
        resultsViewController?.setStyle()
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
    }

    private func configureTableView() {
        placeCardsTableView.contentInset = UIEdgeInsets(top: headerSectionHeight, left: 0, bottom: 0, right: 0)
        placeCardsTableView.dataSource = dataSource
        placeCardsTableView.delegate = self
        placeCardsTableView.tableFooterView = UIView()
        dataSource?.viewController = self
    }

    private func loadDataSource(reloadMapCard: Bool = false) {
        guard let dataSource = dataSource else { return }

        titleLabel.text = dataSource.place.placeableName

        dataSource.loadPhoto(success: { [weak self] image in
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                strongSelf.placeImageView.subviews.forEach { $0.removeFromSuperview() }
                strongSelf.placeImageView.image = image
                strongSelf.placeImageView.contentMode = .scaleAspectFill
                strongSelf.placeImageView.addSubview(strongSelf.visualEffectView)
            }
        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })

        dataSource.loadSightsAndEateries(success: { [weak self] indexPaths in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.placeCardsTableView.reloadRows(at: indexPaths, with: .fade)
            }
        }, failure: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.logErrorEvent(error)
        })

        if reloadMapCard {
            placeCardsTableView.reloadRows(at: [dataSource.mapCardCellIndexPath], with: .fade)
        }
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
        guard let dataSource = dataSource else { return 0 }

        switch indexPath.row {
        case 0:
            return dataSource.mapCardCellHeight
        default:
            return dataSource.sightsCardCellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }

        if indexPath.row == 0 {
            logEvent(contentType: "select map card cell", title)

            if let mapUrl = dataSource.place.placeableMapUrl {
                openUrl(mapUrl)
            } else if let placeId = dataSource.place.placeableId {
                networkService.getPlace(with: placeId, success: { [weak self] place in
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
        let searchBarText = searchController?.searchBar.text ?? "Couldn't get search bar text"
        let placeId = place.placeID ?? "Couldn't get place ID"
        logSearchEvent(searchTerm: searchBarText, placeId: placeId)
        searchController?.searchBar.text = nil // reset to search bar text

        dismiss(animated: true, completion: {
            guard let dataSource = self.dataSource else { return }

            dataSource.place = place
            self.loadDataSource(reloadMapCard: true)
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
