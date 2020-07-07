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
    private var placeData: Place?
    private var placeBackgroundImage: UIImage?
    private var defaultSearchBarYOffset: CGFloat {
        return  (view.bounds.height / 2) - (searchBarViewHeight / 2) - 50
    }
    private var dataPreloaded: Bool {
        placeData != nil && placeBackgroundImage != nil
    }

    static let toSearchDetailVCSegue = "toSearchDetailVCSegue"
    private let searchBarViewHeight: CGFloat = 45.0

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

    // Note: When the user does not have Dark Mode on, this does nothing.
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

    // MARK: - Cancellables

    private var placeCancellable: AnyCancellable?

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fadeInTitleAndButton()
        searchBarContainerView.frame.origin.y = defaultSearchBarYOffset
        searchController?.searchBar.text = ""
    }

    private func fadeInTitleAndButton() {
        titleLabel.alpha = 0
        randomButton.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseInOut, animations: {
            self.titleLabel.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.8, delay: 1.3, options: .curveEaseInOut, animations: {
            self.randomButton.alpha = 1
        }, completion: nil)
    }

    private func addViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(titleLabel)
        view.addSubview(randomButton)
        view.addSubview(feedbackButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-200)
        }

        randomButton.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(90)
        }

        feedbackButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        }

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.setAutocompleteFilter(.city)
        resultsViewController?.setStyle()

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.setStyle()
        searchController?.delegate = self

        if let searchBar = searchController?.searchBar {
            let frame = CGRect(x: 0, y: defaultSearchBarYOffset, width: view.bounds.width, height: searchBarViewHeight)
            searchBarContainerView = UIView(frame: frame)
            searchBarContainerView.alpha = 0
            searchBarContainerView.addSubview(searchBar)
            view.addSubview(searchBarContainerView)

            searchBarContainerView.snp.makeConstraints { make in
                make.centerY.equalToSuperview().offset(-60)
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
        searchController?.searchBar.text = nil
        searchBarContainerView.frame = CGRect(x: 0, y: defaultSearchBarYOffset, width: view.bounds.width, height: searchBarViewHeight)
        titleLabel.alpha = 1
    }

    // MARK: - Button selector methods

    @objc
    func randomButtonTapped() {
        logEvent(contentType: "random button tapped", title)
        if dataPreloaded {
            performSegue(withIdentifier: SearchViewController.toSearchDetailVCSegue, sender: nil)
            return
        }

        guard let randomCity = getRandomCity() else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)
        
        placeCancellable = fetchCityAndBackgroundPhoto(cityName: randomCity)?
            .sink(receiveCompletion: { [weak self] completion in
                loadingVC.remove()
                if case let Subscribers.Completion.failure(error) = completion {
                    self?.logErrorEvent(error)
                }
            }, receiveValue: { [weak self] image in
                self?.placeBackgroundImage = image
                self?.performSegue(withIdentifier: SearchViewController.toSearchDetailVCSegue, sender: nil)
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

    // MARK: - Segue method

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SearchDetailViewController,
            let place = placeData,
            let backgroundImage = placeBackgroundImage else {
            return
        }

        destinationVC.dataSource = SearchDetailDataSource(place: place)
        destinationVC.backgroundImage = backgroundImage
        placeData = nil
        placeBackgroundImage = nil
    }

    // MARK: - Networking
    
    private func fetchCityAndBackgroundPhoto(cityName: String) -> AnyPublisher<UIImage, Error>? {
        (API.PlaceSearch.loadPlace(name: cityName, queryType: .placeByName)?
            .tryMap { [weak self] place -> String in
                guard let strongSelf = self, let photoRef = place.photos?.first?.photoReference else {
                    throw NetworkError.noImage
                }
                strongSelf.placeData = place
                return photoRef
        }
            .compactMap { API.PlaceSearch.loadGooglePhotoAPI(photoRef: $0, maxHeight: Int(UIScreen.main.bounds.height)) } // strips nil
            .flatMap { $0 } // converts into correct publisher so sink works
            .eraseToAnyPublisher())
    }

    // MARK: - TraitCollection

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else {
            return
        }
        if traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
            if traitCollection.userInterfaceStyle == .dark {
                overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            } else {
                overlayView.backgroundColor = .clear
            }
        }
    }
}

extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    // Handle the user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        let searchBarText = searchController?.searchBar.text ?? "Couldn't get search bar text"
        let placeId = place.placeID ?? "Couldn't get place ID"
        logSearchEvent(searchTerm: searchBarText, placeId: placeId)

        guard let placeModel = Place(from: place) else {
            dismiss(animated: true, completion: nil)
            return
        }

        placeData = placeModel

        dismiss(animated: true, completion: {
            self.resetSearchUI()
            let loadingVC = LoadingViewController()
            self.add(loadingVC)
            self.placeCancellable = API.PlaceSearch.loadGooglePhoto(placeId: placeId)
                .sink(receiveCompletion: { _ in
                    loadingVC.remove()
                }, receiveValue: { [weak self] image in
                    self?.placeBackgroundImage = image
                    self?.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
                })
        })
    }

    // Handle the error
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        logErrorEvent(error)
    }
}

extension SearchViewController: UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
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

extension SearchViewController: RandomCitySelectable, Loggable {}
