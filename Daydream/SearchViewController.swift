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
    private var searchBarView: UIView!
    private let searchBarViewHeight: CGFloat = 45.0
    private var placeData: Place?
    private var placeBackgroundImage: UIImage?
    private var defaultSearchBarYOffset: CGFloat {
        return  (view.bounds.height / 2) - (searchBarViewHeight / 2) - 50
    }
    private let networkService = NetworkService()

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

    private var placeCancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        addSearchController()
        addProgrammaticComponents()
        fadeInTitleAndButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fadeInTitleAndButton()
        searchBarView.frame.origin.y = defaultSearchBarYOffset
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

    private func addSearchController() {
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.setStyle()
        searchController?.delegate = self

        resultsViewController?.setAutocompleteFilter(.city)
        resultsViewController?.setStyle()

        let frame = CGRect(x: 0, y: defaultSearchBarYOffset, width: view.bounds.width, height: searchBarViewHeight)
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

    private func addProgrammaticComponents() {
        view.addSubview(titleLabel)
        view.addSubview(randomButton)
        view.addSubview(feedbackButton)

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
    }

    private func resetSearchUI() {
        searchController?.searchBar.text = nil
        searchBarView.frame = CGRect(x: 0, y: defaultSearchBarYOffset, width: view.bounds.width, height: searchBarViewHeight)
        titleLabel.alpha = 1
    }

    // MARK: - Button selector method

    @objc
    func randomButtonTapped() {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity(), let url = GooglePlaceTextSearchRoute(name: randomCity, queryType: .placeByName)?.url else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)

        placeCancellable = networkService.loadPlaces(url: url)
            .tryMap({ places -> Place in
                guard let firstPlace = places.first else {
                    throw NetworkError.insufficientResults
                }
                return firstPlace
            })
            .receive(on: DispatchQueue.main)
            .flatMap({ [weak self] place -> Future<UIImage, Error> in
                self?.placeData = place
                return NetworkService().loadPhoto(placeId: place.placeId)
            })
            .sink(receiveCompletion: { [weak self] completion in
                loadingVC.remove()
                if case let Subscribers.Completion.failure(error) = completion {
                    self?.logErrorEvent(error)
                }
            }, receiveValue: { [weak self] image in
                self?.placeBackgroundImage = image
                self?.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
            })
    }

    @objc
    private func feedbackButtonTapped() {
        var message: String?

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            message = "The current app version is \(appVersion)"
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
            self.placeCancellable = self.networkService.loadPhoto(placeId: placeId)
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
            self.searchBarView.frame.origin.y = 65.0
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
