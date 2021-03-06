//
//  SearchDetailDataSource.swift
//  Daydream
//
//  Created by Raymond Kim on 4/10/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation
import Combine

final class SearchDetailDataSource: NSObject, UITableViewDataSource {

    enum LoadingState {
        case uninitiated, loading, results, error
    }

    var place: Place
    var sights: [Place]?
    var eateries: [Eatable]?
    private var prevEateries: [Eatable]?
    private var eateriesIsEqualToPrevious: Bool {
        var eateriesIsEqualToPrevious = false

        guard let eateries = eateries,
            let prevEateries = prevEateries,
            eateries.count > 2 && prevEateries.count > 2,
            eateries[0].type == prevEateries[0].type else {
            return false
        }

        if let eateries = eateries as? [Eatery], let prevEateries = prevEateries as? [Eatery] {
            eateries.enumerated().forEach { index, eatery in
                eateriesIsEqualToPrevious = eatery == prevEateries[index]
            }
        } else if let eateries = eateries as? [Place], let prevEateries = prevEateries as? [Place] {
            eateries.enumerated().forEach { index, eatery in
                eateriesIsEqualToPrevious = eatery == prevEateries[index]
            }
        }

        return eateriesIsEqualToPrevious
    }
    weak var viewController: SearchDetailViewController?
    var sightsLoadingState: LoadingState = .uninitiated
    var eateriesLoadingState: LoadingState = .uninitiated

    let mapCardCellHeight: CGFloat = 186
    var sightsCardCellHeight: CGFloat {
        return sightsLoadingState == .error ? SightsCardCell.errorHeight: SightsCardCell.defaultHeight
    }
    var eateriesCardCellHeight: CGFloat {
        return eateriesLoadingState == .error ? EateriesCardCell.errorHeight: EateriesCardCell.defaultHeight
    }
    static let mapIndexPath = IndexPath(row: 0, section: 0)
    static let sightsIndexPath = IndexPath(row: 1, section: 0)
    static let eateriesIndexPath = IndexPath(row: 2, section: 0)

    init(place: Place) {
        self.place = place
    }

    func loadPhoto() -> AnyPublisher<UIImage, Error>? {
        API.PlaceSearch.loadGooglePhoto(photoRef: place.photoRef, maxHeight: Int(UIScreen.main.bounds.height))
    }

    func loadSights(name: String, location: CLLocationCoordinate2D, queryType: API.PlaceSearch.TextSearchRoute.QueryType) -> AnyPublisher<Void, Error>? {
        return API.PlaceSearch.loadPlaces(name: name, location: location, queryType: queryType)?
            .mapError { [weak self] error -> Error in
                self?.sightsLoadingState = .error
                return error
            }
            .map { [weak self] places -> Void in
                self?.sights = places
                self?.sightsLoadingState = .results
                return
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func loadEateries() -> AnyPublisher<Void, Error>? {
        return API.EaterySearch.loadEateries(place: place)?
            .mapError { [weak self] error -> Error in
                self?.eateriesLoadingState = .error
                return error
            }
            .map { [weak self] eateries -> Void in
                self?.eateries = eateries
                self?.eateriesLoadingState = .results
                return
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    // swiftlint:disable cyclomatic_complexity
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case SearchDetailDataSource.mapIndexPath:
            guard let mapCardCell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath) as? MapCardCell else {
                return UITableViewCell()
            }

            mapCardCell.place = place

            return mapCardCell
        case SearchDetailDataSource.sightsIndexPath:
            guard let sightsCardCell = tableView.dequeueReusableCell(withIdentifier: "sightsCardCell", for: indexPath) as? SightsCardCell else {
                return UITableViewCell()
            }

            sightsCardCell.delegate = viewController

            switch sightsLoadingState {
            case .loading:
                sightsCardCell.configureLoading()
            case .results:
                sightsCardCell.sights = sights
            case .error:
                sightsCardCell.configureError()
            case .uninitiated:
                return sightsCardCell
            }

            return sightsCardCell
        case SearchDetailDataSource.eateriesIndexPath:
            guard let eateriesCardCell = tableView.dequeueReusableCell(withIdentifier: "eateriesCardCell", for: indexPath) as? EateriesCardCell else {
                return UITableViewCell()
            }

            eateriesCardCell.delegate = viewController

            switch eateriesLoadingState {
            case .loading:
                eateriesCardCell.configureLoading()
            case .results:
                eateriesCardCell.eateries = eateries
            case .error:
                eateriesCardCell.configureError()
            case .uninitiated:
                return eateriesCardCell
            }

            return eateriesCardCell
        default:
            return UITableViewCell()
        }
    }
}
