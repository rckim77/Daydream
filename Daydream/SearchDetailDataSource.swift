//
//  SearchDetailDataSource.swift
//  Daydream
//
//  Created by Raymond Kim on 4/10/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import Combine

class SearchDetailDataSource: NSObject, UITableViewDataSource {

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

    private let networkService = NetworkService()
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

    func loadPhoto() -> Future<UIImage, Error> {
        return networkService.loadGooglePhoto(placeId: place.placeId)
    }

    func loadSights(url: URL) -> AnyPublisher<Void, Error> {
        return networkService.loadPlaces(url: url)
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

    func loadEateries(request: URLRequest, fallbackUrl: URL) -> AnyPublisher<Void, Error> {
        return networkService.loadEateries(place: place, urlRequest: request, fallbackUrl: fallbackUrl)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath)

            guard let mapCardCell = cell as? MapCardCell else {
                return cell
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
