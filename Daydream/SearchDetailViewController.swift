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
import SnapKit
import Combine

final class SearchDetailViewController: UIViewController {

    var dataSource: SearchDetailDataSource?
    var backgroundImage: UIImage?
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var mapView: GMSMapView?
    private lazy var visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.frame = view.bounds
        return visualEffectView
    }()

    // MARK: - Cancellable objects

    private var sightsCancellable: AnyCancellable?
    private var eateriesCancellable: AnyCancellable?
    private var loadPhotoCancellable: AnyCancellable?
    private var loadPlaceByNameCancellable: AnyCancellable?
    private var loadMapUrlCancellable: AnyCancellable?

    // MARK: - Constants

    private let headerContentInset: CGFloat = 138
    private let headerFadeOutStartPoint: CGFloat = 100
    private let headerFadeOutEndPoint: CGFloat = 80
    private let floatingTitleViewFadeInStartPoint: CGFloat = 85
    private let floatingTitleViewFadeInEndPoint: CGFloat = 65

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    private lazy var randomCityButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("arrow.clockwise")
        button.addTarget(self, action: #selector(randomCityButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()

    private lazy var homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("house.fill")
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeCardsTableView: UITableView!
    @IBOutlet weak var floatingTitleView: DesignableView!
    @IBOutlet weak var floatingTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        addProgrammaticComponents()
        configureFloatingTitleLabel()

        placeImageView.image = backgroundImage
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.addSubview(visualEffectView)

        dataSource?.sightsLoadingState = .loading
        dataSource?.eateriesLoadingState = .loading
        placeCardsTableView.reloadData()
        loadDataSource(reloadMapCard: false, fetchBackground: false, completion: {})
    }

    // MARK: - Search

    private func addProgrammaticComponents() {
        view.addSubview(titleLabel)
        view.addSubview(randomCityButton)
        view.insertSubview(homeButton, belowSubview: placeCardsTableView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.leading.equalToSuperview().offset(12)
        }

        randomCityButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(40)
            make.leading.equalTo(titleLabel.snp.trailing).offset(6)
        }

        homeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(40)
            make.leading.equalTo(randomCityButton.snp.trailing)
            make.trailing.equalToSuperview().inset(8)
        }

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.setAutocompleteFilter(.city)
        resultsViewController?.setStyle()

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.setStyle()

        if let searchBar = searchController?.searchBar {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 45))
            containerView.addSubview(searchBar)
            view.addSubview(containerView)

            containerView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(45)
            }

            searchBar.sizeToFit()

            // When UISearchController presents the results view, present it in
            // this view controller, not one further up the chain.
            definesPresentationContext = true
        }
    }

    // MARK: - Reload methods

    private func loadDataSource(reloadMapCard: Bool = false, fetchBackground: Bool = true, completion: @escaping(() -> Void)) {
        guard let dataSource = dataSource else {
            return
        }

        titleLabel.text = dataSource.place.name
        floatingTitleLabel.text = dataSource.place.name

        if fetchBackground {
            fetchBackgroundPhoto()
        }

        sightsCancellable = dataSource.loadSights(name: dataSource.place.name, location: dataSource.place.coordinate, queryType: .touristSpots)?
            .sink(receiveCompletion: { [weak self] receiveCompletion in
                if case let Subscribers.Completion.failure(error) = receiveCompletion {
                    self?.logErrorEvent(error)
                }
                self?.placeCardsTableView.reloadRows(at: [SearchDetailDataSource.sightsIndexPath], with: .fade)
                completion()
                }, receiveValue: { [weak self] _ in
                    self?.placeCardsTableView.reloadRows(at: [SearchDetailDataSource.sightsIndexPath], with: .fade)
            })

        eateriesCancellable = dataSource.loadEateries()?
            .sink(receiveCompletion: { [weak self] receiveCompletion in
                if case let Subscribers.Completion.failure(error) = receiveCompletion {
                    self?.logErrorEvent(error)
                }
                self?.placeCardsTableView.reloadRows(at: [SearchDetailDataSource.eateriesIndexPath], with: .fade)
                completion()
                }, receiveValue: { [weak self] _ in
                    self?.placeCardsTableView.reloadRows(at: [SearchDetailDataSource.eateriesIndexPath], with: .fade)
            })

        if reloadMapCard {
            placeCardsTableView.reloadRows(at: [SearchDetailDataSource.mapIndexPath], with: .fade)
        }
    }

    private func fetchBackgroundPhoto() {
        guard let dataSource = dataSource else {
            return
        }

        loadPhotoCancellable = dataSource.loadPhoto()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] receiveCompletion in
                guard let strongSelf = self else {
                    return
                }
                if case let Subscribers.Completion.failure(error) = receiveCompletion {
                    strongSelf.logErrorEvent(error)
                }
            }, receiveValue: { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.placeImageView.subviews.forEach { $0.removeFromSuperview() }
                strongSelf.placeImageView.image = image
                strongSelf.placeImageView.contentMode = .scaleAspectFill
                strongSelf.placeImageView.addSubview(strongSelf.visualEffectView)
            })
    }

    // MARK: - Configuration methods

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

    // MARK: - Button selector methods

    @objc
    private func homeButtonTapped() {
        logEvent(contentType: "home button tapped", title)
        dismiss(animated: true, completion: nil)
    }

    @objc
    func randomCityButtonTapped() {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity() else {
            return
        }

        let loadingVC = LoadingViewController()
        add(loadingVC)
        dataSource?.sightsLoadingState = .loading
        dataSource?.eateriesLoadingState = .loading
        placeCardsTableView.reloadData()

        loadPlaceByNameCancellable = API.PlaceSearch.loadPlace(name: randomCity, queryType: .placeByName)?
            .sink(receiveCompletion: { [weak self] completion in
                if case let Subscribers.Completion.failure(error) = completion {
                    loadingVC.remove()
                    self?.logErrorEvent(error)
                }
            }, receiveValue: { [weak self] place in
                self?.dataSource?.place = place
                self?.loadDataSource(reloadMapCard: true, completion: {
                    loadingVC.remove()
                })
            })
    }
}

extension SearchDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataSource = dataSource else {
            return 0
        }

        switch indexPath.row {
        case 0:
            return dataSource.mapCardCellHeight
        case 1:
            return dataSource.sightsCardCellHeight
        case 2:
            return dataSource.eateriesCardCellHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource, indexPath.row == 0 else {
            return
        }

        logEvent(contentType: "select map card cell", title)

        if let mapUrl = dataSource.place.mapUrl {
            openUrl(mapUrl)
        } else {
            loadMapUrlCancellable = API.PlaceSearch.getMapUrl(placeId: dataSource.place.placeId)?
                .sink(receiveCompletion: { [weak self] completion in
                    if case let Subscribers.Completion.failure(error) = completion {
                        self?.logErrorEvent(error)
                    }
                }, receiveValue: { url in
                    UIApplication.shared.open(url, options: [:])
                })
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
        let padding: CGFloat = 12
        let statusBarOffset = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let notchOffset = statusBarOffset - padding
        let fadeOutStartPoint = -headerContentInset - padding - notchOffset
        let fadeOutEndPoint = -headerContentInset - notchOffset
        if yOffset > fadeOutStartPoint {
            let calculatedAlpha = (-yOffset + fadeOutEndPoint) / padding
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

extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        let searchBarText = searchController?.searchBar.text ?? "Couldn't get search bar text"
        let placeId = place.placeID ?? "Couldn't get place ID"
        logSearchEvent(searchTerm: searchBarText, placeId: placeId)
        searchController?.searchBar.text = nil // reset to search bar text

        guard let placeModel = Place(from: place) else {
            dismiss(animated: true, completion: nil)
            return
        }

        dismiss(animated: true, completion: {
            guard let dataSource = self.dataSource else {
                return
            }
            dataSource.place = placeModel
            let loadingVC = LoadingViewController()
            self.add(loadingVC)
            self.loadDataSource(reloadMapCard: true, completion: {
                loadingVC.remove()
            })
        })
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        logErrorEvent(error)
    }
}

extension SearchDetailViewController: SightsCardCellDelegate {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Place) {
        logEvent(contentType: "select point of interest", title)
        guard let mapVC = MapViewController(place: place) else {
            return
        }
        present(mapVC, animated: true)
    }

    func sightsCardCellDidTapBusinessStatusButton(_ businessStatus: PlaceBusinessStatus) {
        let alert = UIAlertController(title: "This place is \(businessStatus.displayValue).", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func sightsCardCellDidTapRetry() {
        randomCityButtonTapped()
    }
}

extension SearchDetailViewController: EateriesCardCellDelegate {
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectEatery eatery: Eatable) {
        logEvent(contentType: "select eatery", title)

        switch eatery.type {
        case .yelp:
            if let url = eatery.eatableUrl {
                openUrl(url)
            }
        case .google:
            guard let mapVC = MapViewController(place: eatery as? Place) else {
                return
            }
            present(mapVC, animated: true)
        }
    }

    func eateriesCardCellDidTapInfoButtonForEateryType(_ type: EateryType) {
        let title = "Top Eateries"
        let message: String
        switch type {
        case .yelp:
            message = "These results are powered by Yelp's Fusion API. Tapping on an eatery will open up Yelp."
        case .google:
            message = "These results are powered by Google's Places API. Tapping on an eatery will open up a map view."
        }
        presentInfoAlertModal(title: title,
                              message: message)
    }

    func eateriesCardCellDidTapRetry() {
        randomCityButtonTapped()
    }
}

extension SearchDetailViewController: RandomCitySelectable, Loggable {}
