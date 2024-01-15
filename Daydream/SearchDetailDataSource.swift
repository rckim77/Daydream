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

enum LoadingState {
    case uninitiated, loading, results, error
}

final class SearchDetailDataSource: NSObject, UITableViewDataSource {

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
    var sightsCarouselLoadingState: LoadingState = .uninitiated
    var eateriesCarouselLoadingState: LoadingState = .uninitiated

    let mapCardCellHeight: CGFloat = 186
    let sightsCarouselCardCellHeight: CGFloat = SightsCarouselTableViewCell.defaultHeight
    let eateriesCarouselCardCellHeight: CGFloat = EateriesCarouselTableViewCell.defaultHeight
    static let mapIndexPath = IndexPath(row: 0, section: 0)
    static let sightsCarouselIndexPath = IndexPath(row: 1, section: 0)
    static let eateriesCarouselIndexPath = IndexPath(row: 2, section: 0)

    init(place: Place) {
        self.place = place
    }

    func loadPhoto() -> AnyPublisher<UIImage, Error>? {
        API.PlaceSearch.loadGooglePhoto(photoRef: place.photoRef, maxHeight: Int(UIScreen.main.bounds.height))
    }

    func loadSights(name: String, location: CLLocationCoordinate2D, queryType: API.PlaceSearch.TextSearchRoute.QueryType) -> AnyPublisher<Void, Error>? {
        return API.PlaceSearch.loadPlaces(name: name, location: location, queryType: queryType)?
            .mapError { [weak self] error -> Error in
                self?.eateriesCarouselLoadingState = .error
                return error
            }
            .map { [weak self] places -> Void in
                self?.sights = places
                self?.sightsCarouselLoadingState = .results
                return
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func loadEateries() -> AnyPublisher<Void, Error>? {
        return API.EaterySearch.loadEateries(place: place)?
            .mapError { [weak self] error -> Error in
                self?.eateriesCarouselLoadingState = .error
                return error
            }
            .map { [weak self] eateries -> Void in
                self?.eateries = eateries
                self?.eateriesCarouselLoadingState = .results
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
        case SearchDetailDataSource.sightsCarouselIndexPath:
            guard let sightsCarouselCell = tableView.dequeueReusableCell(withIdentifier: "sightsCarouselTableViewCell", for: indexPath) as? SightsCarouselTableViewCell else {
                return UITableViewCell()
            }
            
            sightsCarouselCell.delegate = viewController
            
            switch sightsCarouselLoadingState {
            case .loading:
                sightsCarouselCell.configureLoading()
            case .results:
                sightsCarouselCell.sights = sights
            case .error:
                sightsCarouselCell.configureError()
            case .uninitiated:
                return sightsCarouselCell
            }
            
            return sightsCarouselCell
        case SearchDetailDataSource.eateriesCarouselIndexPath:
            guard let eateriesCarouselCell = tableView.dequeueReusableCell(withIdentifier: "eateriesCarouselTableViewCell", for: indexPath) as? EateriesCarouselTableViewCell else {
                return UITableViewCell()
            }

            eateriesCarouselCell.delegate = viewController

            switch eateriesCarouselLoadingState {
            case .loading:
                eateriesCarouselCell.configureLoading()
            case .results:
                eateriesCarouselCell.eateries = eateries
            case .error:
                eateriesCarouselCell.configureError()
            case .uninitiated:
                return eateriesCarouselCell
            }

            return eateriesCarouselCell
        default:
            return UITableViewCell()
        }
    }
}
