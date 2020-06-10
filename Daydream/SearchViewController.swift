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

final class SearchViewController: UIViewController {

    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var searchBarView: UIView!
    private let searchBarViewHeight: CGFloat = 45.0
    private var placeData: Placeable?
    private var placeBackgroundImage: UIImage?
    private var defaultSearchBarYOffset: CGFloat {
        return  (view.bounds.height / 2) - (searchBarViewHeight / 2) - 50
    }
    private let networkService = NetworkService()

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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var randomBtn: UIButton! {
        didSet {
            randomBtn.addRoundedCorners(radius: 16)
            randomBtn.addBorder()
            if #available(iOS 13.4, *) {
                randomBtn.pointerStyleProvider = buttonProvider
            }
        }
    }

    @IBAction func randomBtnTapped(_ sender: Any) {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity() else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)

        networkService.getPlaceId(placeName: randomCity, completion: { [weak self] result in
            loadingVC.remove()
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let place):
                strongSelf.placeData = place
                strongSelf.networkService.loadPhoto(placeId: place.placeableId, completion: { [weak self] result in
                    guard let strongSelf = self else {
                        return
                    }
                    if case .success(let image) = result {
                        strongSelf.placeBackgroundImage = image
                    }
                    strongSelf.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
                })
            case .failure(let error):
                strongSelf.logErrorEvent(error)
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        addSearchController()
        addFeedbackButton()
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

    private func addFeedbackButton() {
        view.addSubview(feedbackButton)
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
        placeData = place

        dismiss(animated: true, completion: {
            self.resetSearchUI()
            let loadingVC = LoadingViewController()
            self.add(loadingVC)
            self.networkService.loadPhoto(placeId: placeId, completion: { [weak self] result in
                loadingVC.remove()
                guard let strongSelf = self else {
                    return
                }

                if case .success(let image) = result {
                    strongSelf.placeBackgroundImage = image
                }

                strongSelf.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
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
