//
//  SearchViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import SnapKit
import Combine

final class SearchViewController: UIViewController {

    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private let searchBarViewHeight: CGFloat = 45.0

    private var placeData: Place?
    private var placeBackgroundImage: UIImage?

    private let curatedCitiesDataSource: CuratedCityCollectionViewDataSource
    private var deviceYOffset: CGFloat {
        isSmallDevice ? 0 : 48
    }
    private var defaultSearchBarYOffset: CGFloat {
        -72 - deviceYOffset
    }
    private var titleLabelCenterYOffset: CGFloat {
        -212 - deviceYOffset
    }
    private var randomButtonYOffset: CGFloat {
        30 - deviceYOffset
    }
    private var defaultSearchBarContainerY: CGFloat?

    private lazy var searchBarContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let image = UIImage(named: "sunriseJungle")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    /// Note: When the user does not have Dark Mode on, this does nothing.
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.4) : .clear
        return view
    }()

    private lazy var titleLabel: CardLabel = {
        let label = CardLabel(textStyle: .largeTitle, text: "Where do you want to go?")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var feedbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Got feedback?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()

    private lazy var randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("Random", for: .normal)
        button.addRoundedCorners(radius: 12)
        button.addBorder(color: .white, width: 1)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
        button.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var curatedCitiesCollectionView: CuratedCityCollectionView = {
        let collectionView = CuratedCityCollectionView(deviceSize: deviceSize, isIpad: UIDevice.current.userInterfaceIdiom == .pad)
        collectionView.delegate = self
        collectionView.dataSource = curatedCitiesDataSource
        return collectionView
    }()

    // MARK: - Cancellables

    private var placeCancellable: AnyCancellable?
    private var curatedCitiesCancellable: AnyCancellable?
    
    // MARK: Init
    
    init() {
        let cityCount = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
        curatedCitiesDataSource = CuratedCityCollectionViewDataSource(cityCount: cityCount)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        fadeInTitleAndButton()
        if let city = getRandomCity() {
            placeCancellable = fetchCityAndBackgroundPhoto(cityName: city)?
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                    self?.placeBackgroundImage = image
                })
        }
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                } else {
                    self.overlayView.backgroundColor = .clear
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fadeInTitleAndButton()
        searchController?.searchBar.text = ""
    }

    private func fadeInTitleAndButton() {
        titleLabel.alpha = 0
        randomButton.alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0.4, options: .curveEaseInOut, animations: {
            self.randomButton.alpha = 1
            self.titleLabel.alpha = 1
        }, completion: nil)
    }

    private func addViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(titleLabel)
        view.addSubview(randomButton)
        view.addSubview(curatedCitiesCollectionView)
        view.addSubview(feedbackButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(titleLabelCenterYOffset)
        }

        randomButton.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(randomButtonYOffset)
        }

        feedbackButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        }
        
        curatedCitiesCollectionView.snp.makeConstraints { make in
            make.height.equalTo(curatedCitiesCollectionView.height)
            make.bottom.equalTo(feedbackButton.snp.top)
            make.leading.trailing.equalToSuperview()
        }

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.setAutocompleteFilter()
        resultsViewController?.setStyle()

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.setStyle()
        searchController?.delegate = self

        if let searchBar = searchController?.searchBar {
            searchBarContainerView.alpha = 0
            searchBarContainerView.addSubview(searchBar)
            view.addSubview(searchBarContainerView)

            searchBarContainerView.snp.makeConstraints { make in
                make.centerY.equalToSuperview().offset(defaultSearchBarYOffset)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(searchBarViewHeight)
            }

            searchBar.sizeToFit()

            // When UISearchController presents the results view, present it in
            // this view controller, not one further up the chain.
            definesPresentationContext = true

            UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseInOut, animations: {
                self.searchBarContainerView.alpha = 1
            }, completion: nil)
        }
    }

    private func resetSearchUI() {
        if let defaultSearchBarContainerY = defaultSearchBarContainerY {
            searchBarContainerView.frame = CGRect(x: 0, y: defaultSearchBarContainerY, width: view.bounds.width, height: searchBarViewHeight)
        }
        titleLabel.alpha = 1
    }
    
    private func resetAndPresentDetailViewController() {
        guard let backgroundImage = placeBackgroundImage, let place = placeData else {
            return
        }
        placeBackgroundImage = nil
        placeData = nil
        let searchDetailVC = SearchDetailViewController(backgroundImage: backgroundImage, place: place)
        searchDetailVC.modalPresentationStyle = .fullScreen
        searchDetailVC.modalTransitionStyle = .crossDissolve
        present(searchDetailVC, animated: true, completion: nil)
    }

    // MARK: - Button selector methods

    @objc
    func randomButtonTapped() {
        if placeBackgroundImage != nil && placeData != nil {
            resetAndPresentDetailViewController()
            return
        }

        guard let randomCity = getRandomCity() else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        placeCancellable = fetchCityAndBackgroundPhoto(cityName: randomCity)?
            .sink(receiveCompletion: { completion in
                loadingVC.remove()
            }, receiveValue: { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.placeBackgroundImage = image
                strongSelf.resetAndPresentDetailViewController()
            })
    }

    @objc
    private func feedbackButtonTapped() {
        var message: String?

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            message = "The current app version is \(appVersion) (\(bundleVersion))."
        }

        let alert = UIAlertController(title: "Got feedback? Email me!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
            self.openUrl("mailto:daydreamiosapp@gmail.com")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Networking
    
    private func fetchCityAndBackgroundPhoto(cityName: String) -> AnyPublisher<UIImage, Error>? {
        API.PlaceSearch.loadPlace(name: cityName, queryType: .placeByName)?
            .tryMap { [weak self] place -> String in
                guard let strongSelf = self, let photoRef = place.photoRef else {
                    throw NetworkError.noImage
                }
                strongSelf.placeData = place
                return photoRef
            }
            .compactMap { API.PlaceSearch.loadGooglePhoto(photoRef: $0, maxHeight: Int(UIScreen.main.bounds.height)) } // strips nil
            .flatMap { $0 } // converts into correct publisher so sink works
            .eraseToAnyPublisher()
    }
    
    // MARK: - Device Orientation Change
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.curatedCitiesCollectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        curatedCitiesCollectionView.updateItemSizeForOrientationChange()
        super.viewWillLayoutSubviews()
    }
}

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    // Handle the user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        let placeId = place.placeID ?? "Couldn't get place ID"

        guard let placeModel = Place(from: place) else {
            dismiss(animated: true, completion: nil)
            return
        }

        placeData = placeModel

        dismiss(animated: true, completion: {
            self.resetSearchUI()
            let loadingVC = LoadingViewController()
            self.add(loadingVC)
            self.placeCancellable = API.PlaceSearch.loadGooglePhotoSDK(placeId: placeId)
                .sink(receiveCompletion: { _ in
                    loadingVC.remove()
                }, receiveValue: { [weak self] image in
                    self?.placeBackgroundImage = image
                    self?.resetAndPresentDetailViewController()
                })
        })
    }

    // Handle the error
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        // log error
    }
}

extension SearchViewController: UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
        defaultSearchBarContainerY = searchBarContainerView.frame.origin.y
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBarContainerView.frame.origin.y = 65.0
            self.titleLabel.alpha = 0
        })
    }

    // Note: only called when the user taps Cancel or out of the search bar to close autocorrect results VC and NOT when
    // the user has tapped on a place.
    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.resetSearchUI()
        })
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CuratedCityCollectionViewCell,
            let place = cell.place,
            let image = cell.placeImage else {
            return
        }
        let searchDetailVC = SearchDetailViewController(backgroundImage: image, place: place)
        searchDetailVC.modalPresentationStyle = .fullScreen
        searchDetailVC.modalTransitionStyle = .crossDissolve
        present(searchDetailVC, animated: true, completion: nil)
    }
}

extension SearchViewController: RandomCitySelectable {}
