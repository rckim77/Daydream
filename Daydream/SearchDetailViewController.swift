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

    private var dataSource: SearchDetailDataSource
    private var backgroundImage: UIImage
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

    private let headerContentInset: CGFloat = 144
    private let headerFadeOutStartPoint: CGFloat = 130
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
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var cardsTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = dataSource
        tableView.register(MapCardCell.self, forCellReuseIdentifier: "mapCardCell")
        tableView.register(SightsCarouselTableViewCell.self, forCellReuseIdentifier: "sightsCarouselTableViewCell")
        tableView.register(SightsCardCell.self, forCellReuseIdentifier: "sightsCardCell")
        tableView.register(EateriesCardCell.self, forCellReuseIdentifier: "eateriesCardCell")
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: headerContentInset, left: 0, bottom: 0, right: 0)
        dataSource.viewController = self
        return tableView
    }()
    
    private lazy var floatingView: FloatingView = {
        let view = FloatingView()
        return view
    }()
    
    init(backgroundImage: UIImage, place: Place) {
        self.backgroundImage = backgroundImage
        self.dataSource = SearchDetailDataSource(place: place)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addProgrammaticComponents()
        configureFloatingTitleLabel()

        dataSource.sightsLoadingState = .loading
        dataSource.eateriesLoadingState = .loading
        cardsTableView.reloadData()
        loadDataSource(reloadMapCard: false, fetchBackground: false, completion: {})
    }

    // MARK: - Search

    private func addProgrammaticComponents() {
        view.addSubview(backgroundImageView)
        backgroundImageView.image = backgroundImage
        backgroundImageView.addSubview(visualEffectView)

        view.addSubview(titleLabel)
        view.addSubview(randomCityButton)
        view.addSubview(homeButton)
        view.addSubview(cardsTableView)
        view.addSubview(floatingView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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
        
        cardsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        floatingView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(8)
            make.centerX.equalToSuperview()
        }

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.setAutocompleteFilter()
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
        titleLabel.text = dataSource.place.name
        floatingView.setTitle(dataSource.place.name)

        if fetchBackground {
            fetchBackgroundPhoto()
        }

        sightsCancellable = dataSource.loadSights(name: dataSource.place.name, location: dataSource.place.coordinate, queryType: .touristSpots)?
            .sink(receiveCompletion: { [weak self] receiveCompletion in
                self?.cardsTableView.reloadRows(at: [SearchDetailDataSource.sightsIndexPath, SearchDetailDataSource.sightsCarouselIndexPath], with: .fade)
                completion()
                }, receiveValue: { [weak self] _ in
                    self?.cardsTableView.reloadRows(at: [SearchDetailDataSource.sightsIndexPath, SearchDetailDataSource.sightsCarouselIndexPath], with: .fade)
            })

        eateriesCancellable = dataSource.loadEateries()?
            .sink(receiveCompletion: { [weak self] receiveCompletion in
                self?.cardsTableView.reloadRows(at: [SearchDetailDataSource.eateriesIndexPath], with: .fade)
                completion()
                }, receiveValue: { [weak self] _ in
                    self?.cardsTableView.reloadRows(at: [SearchDetailDataSource.eateriesIndexPath], with: .fade)
            })

        if reloadMapCard {
            cardsTableView.reloadRows(at: [SearchDetailDataSource.mapIndexPath], with: .fade)
        }
    }

    private func fetchBackgroundPhoto() {
        loadPhotoCancellable = dataSource.loadPhoto()?
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.backgroundImageView.subviews.forEach { $0.removeFromSuperview() }
                strongSelf.backgroundImageView.image = image
                strongSelf.backgroundImageView.addSubview(strongSelf.visualEffectView)
            })
    }

    private func configureFloatingTitleLabel() {
        floatingView.alpha = 0
    }

    // MARK: - Button selector methods

    @objc
    private func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func randomCityButtonTapped() {
        guard let randomCity = getRandomCity() else {
            return
        }

        let loadingVC = LoadingViewController()
        add(loadingVC)
        dataSource.sightsLoadingState = .loading
        dataSource.eateriesLoadingState = .loading
        cardsTableView.reloadData()

        loadPlaceByNameCancellable = API.PlaceSearch.loadPlace(name: randomCity, queryType: .placeByName)?
            .sink(receiveCompletion: { completion in
                if case Subscribers.Completion.failure(_) = completion {
                    loadingVC.remove()
                }
            }, receiveValue: { [weak self] place in
                self?.dataSource.place = place
                self?.loadDataSource(reloadMapCard: true, completion: {
                    loadingVC.remove()
                })
            })
    }
}

extension SearchDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return dataSource.mapCardCellHeight
        case 1:
            return dataSource.sightsCardCellHeight
        case 2:
            return dataSource.eateriesCardCellHeight
        case 3:
            return dataSource.sightsCarouselCardCellHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else {
            return
        }

        if let mapUrl = dataSource.place.mapUrl {
            openUrl(mapUrl)
        } else {
            loadMapUrlCancellable = API.PlaceSearch.getMapUrl(placeId: dataSource.place.placeId)?
                .sink(receiveCompletion: { _ in
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
            view.insertSubview(floatingView, aboveSubview: cardsTableView)
        } else {
            searchController?.searchBar.alpha = 1
        }
    }

    private func transitionHeader(_ yOffset: CGFloat) {
        if yOffset >= -headerFadeOutStartPoint {
            let calculatedHeaderAlpha = (-yOffset - headerFadeOutEndPoint) / (headerFadeOutStartPoint - headerFadeOutEndPoint)
            view.insertSubview(cardsTableView, aboveSubview: homeButton)
            titleLabel.alpha = min(calculatedHeaderAlpha, 1)
            randomCityButton.alpha = min(calculatedHeaderAlpha, 1)
            homeButton.alpha = min(calculatedHeaderAlpha, 1)
        } else {
            view.insertSubview(cardsTableView, aboveSubview: backgroundImageView)
            titleLabel.alpha = 1
            randomCityButton.alpha = 1
            homeButton.alpha = 1
        }
    }

    private func transitionFloatingTitleLabel(_ yOffset: CGFloat) {
        if yOffset >= -floatingTitleViewFadeInStartPoint {
            let range = floatingTitleViewFadeInStartPoint - floatingTitleViewFadeInEndPoint
            let calculatedAlpha = 1 - ((-yOffset - floatingTitleViewFadeInEndPoint) / range)
            floatingView.alpha = min(calculatedAlpha, 1)
        } else {
            floatingView.alpha = 0
        }
    }
}

extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.searchBar.text = nil // reset to search bar text

        guard let placeModel = Place(from: place) else {
            dismiss(animated: true, completion: nil)
            return
        }

        dismiss(animated: true, completion: {
            self.dataSource.place = placeModel
            let loadingVC = LoadingViewController()
            self.add(loadingVC)
            self.loadDataSource(reloadMapCard: true, completion: {
                loadingVC.remove()
            })
        })
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        // log error
    }
}

extension SearchDetailViewController: SightsCardCellDelegate {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Place) {
        guard let mapVC = MapViewController(place: place) else {
            return
        }
        mapVC.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .pad ? .fullScreen : .automatic
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

extension SearchDetailViewController: RandomCitySelectable {}
