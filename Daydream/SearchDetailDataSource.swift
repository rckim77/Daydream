//
//  SearchDetailDataSource.swift
//  Daydream
//
//  Created by Raymond Kim on 4/10/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

class SearchDetailDataSource: NSObject, UITableViewDataSource {

    var place: Placeable
    var pointsOfInterest: [Placeable]?
    var eateries: [Eatery]?
    private var prevEateries: [Eatery]?
    var fallbackEateries: [Placeable]?
    private var prevFallbackEateries: [Placeable]?
    weak var viewController: SearchDetailViewController?
    var isLoading = false

    private let networkService = NetworkService()
    let mapCardCellHeight: CGFloat = 190
    let mapCardCellIndexPath = IndexPath(row: 0, section: 0)
    let sightsCardCellHeight: CGFloat = 600
    let sightsCardCellIndexPath = IndexPath(row: 1, section: 0)
    let eateriesCardCellIndexPath = IndexPath(row: 2, section: 0)

    init(place: Placeable) {
        self.place = place
    }

    func loadPhoto(success: @escaping(_ image: UIImage) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        guard let placeId = place.placeableId else {
            return
        }
        networkService.loadPhoto(with: placeId, success: { photo in
            success(photo)
        }, failure: { error in
            failure(error)
        })
    }

    func loadSightsAndEateries(success: @escaping(_ indexPaths: [IndexPath]) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadSightsAndEateries(with: place, success: { [weak self] sights, eateries in
            guard let strongSelf = self else {
                failure(nil)
                return
            }

            strongSelf.pointsOfInterest = sights
            strongSelf.isLoading = false

            if !eateries.isEmpty {
                strongSelf.prevEateries = strongSelf.eateries
                strongSelf.eateries = eateries
                strongSelf.fallbackEateries = nil
                strongSelf.prevFallbackEateries = nil
                success([strongSelf.sightsCardCellIndexPath, strongSelf.eateriesCardCellIndexPath])
            } else {
                strongSelf.networkService.loadGoogleRestaurants(place: strongSelf.place, success: { [weak self] restaurants in
                    guard let strongSelf = self else {
                        failure(nil)
                        return
                    }
                    strongSelf.prevFallbackEateries = strongSelf.fallbackEateries
                    strongSelf.fallbackEateries = restaurants
                    strongSelf.eateries = nil
                    strongSelf.prevEateries = nil
                    success([strongSelf.sightsCardCellIndexPath, strongSelf.eateriesCardCellIndexPath])
                }, failure: { error in
                    failure(error)
                })
            }
        }, failure: { error in
            failure(error)
        })
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
        case mapCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath)

            guard let mapCardCell = cell as? MapCardCell else {
                return cell
            }

            mapCardCell.place = place

            return mapCardCell
        case sightsCardCellIndexPath:
            guard let sightsCardCell = tableView.dequeueReusableCell(withIdentifier: "sightsCardCell", for: indexPath) as? SightsCardCell else {
                return UITableViewCell()
            }

            sightsCardCell.delegate = viewController

            if isLoading {
                sightsCardCell.configureLoading()
            } else {
                sightsCardCell.pointsOfInterest = pointsOfInterest
            }

            return sightsCardCell
        case eateriesCardCellIndexPath:
            guard let eateriesCardCell = tableView.dequeueReusableCell(withIdentifier: "eateriesCardCell", for: indexPath) as? EateriesCardCell else {
                return UITableViewCell()
            }

            eateriesCardCell.delegate = viewController

            if isLoading {
                eateriesCardCell.configureLoading()
            } else if let prevEateries = prevEateries, let eateries = eateries, prevEateries == eateries {
                // this is for when the user is simply scrolling and hasn't reloaded
                return eateriesCardCell
            } else if let prevFallbackEateries = prevFallbackEateries as? [Place],
                let fallbackEateries = fallbackEateries as? [Place],
                    prevFallbackEateries == fallbackEateries {
                // this is for when the user is simply scrolling and hasn't reloaded
                return eateriesCardCell
            } else if let eateries = eateries, eateries.count > 2, eateries != prevEateries {
                eateriesCardCell.configure(eateries)
                prevEateries = eateries
            } else if let fallbackEateries = fallbackEateries, fallbackEateries.count > 2 {
                eateriesCardCell.configureWithFallbackEateries(fallbackEateries)
                prevFallbackEateries = fallbackEateries
            }

            return eateriesCardCell
        default:
            return UITableViewCell()
        }
    }
}
