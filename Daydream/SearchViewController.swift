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
    private var resultView: UITextView?
    private var searchBarView: UIView!
    private let searchBarViewHeight: CGFloat = 45.0
    private var placeData: Placeable?
    private var defaultSearchBarYOffset: CGFloat {
        return  (view.bounds.height / 2) - (searchBarViewHeight / 2)
    }

    private lazy var feedbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Got feedback?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        return button
    }()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var randomBtn: UIButton! {
        didSet {
            randomBtn.addRoundedCorners(radius: 16)
            randomBtn.addBorder()
        }
    }

    @IBAction func randomBtnTapped(_ sender: Any) {
        logEvent(contentType: "random button tapped", title)
        guard let randomCity = getRandomCity() else {
            return
        }
        let loadingVC = LoadingViewController()
        add(loadingVC)

        NetworkService().getPlaceId(with: randomCity, success: { [weak self] place in
            loadingVC.remove()
            guard let strongSelf = self else {
                return

            }

            strongSelf.placeData = place
            strongSelf.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
        }, failure: { [weak self] error in
            loadingVC.remove()
            guard let strongSelf = self else {
                return

            }
            strongSelf.logErrorEvent(error)
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

    // MARK: - Button selector method

    @objc
    private func feedbackButtonTapped() {
        let alert = UIAlertController(title: "Got feedback? Email me!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
            self.openUrl("mailto:daydreamiosapp@gmail.com")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Segue method

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SearchDetailViewController, let place = placeData {
            destinationVC.dataSource = SearchDetailDataSource(place: place)
        }
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
            // reset search bar
            self.searchController?.searchBar.text = nil
            let initialFrame = CGRect(x: 0, y: self.defaultSearchBarYOffset, width: self.view.bounds.width, height: self.searchBarViewHeight)
            self.searchBarView.frame = initialFrame
            self.performSegue(withIdentifier: "toSearchDetailVCSegue", sender: nil)
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

    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.3, animations: {
            let yCoordinate = self.view.bounds.height
            self.searchBarView.frame.origin.y = (yCoordinate / 2) - (self.searchBarViewHeight / 2)
            self.titleLabel.alpha = 1
        })
    }
}

extension SearchViewController: RandomCitySelectable, Loggable {}
