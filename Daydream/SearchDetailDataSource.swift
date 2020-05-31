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
    var fallbackEateries: [Placeable]?
    weak var viewController: SearchDetailViewController?

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

            if !eateries.isEmpty {
                strongSelf.eateries = eateries
                strongSelf.fallbackEateries = nil
                success([strongSelf.sightsCardCellIndexPath, strongSelf.eateriesCardCellIndexPath])
            } else { // fallback to Google restaurants search
                strongSelf.networkService.loadGoogleRestaurants(place: strongSelf.place, success: { [weak self] restaurants in
                    guard let strongSelf = self else {
                        failure(nil)
                        return
                    }
                    strongSelf.fallbackEateries = restaurants
                    strongSelf.eateries = nil
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case mapCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath)

            if let mapCardCell = cell as? MapCardCell {
                mapCardCell.place = place

                return mapCardCell
            }

            return cell
        case sightsCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sightsCardCell", for: indexPath)

            if let sightsCardCell = cell as? SightsCardCell {
                sightsCardCell.delegate = viewController
                sightsCardCell.pointsOfInterest = pointsOfInterest

                return sightsCardCell
            }

            return cell
        case eateriesCardCellIndexPath:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eateriesCardCell", for: indexPath)

            if let eateriesCardCell = cell as? EateriesCardCell {
                eateriesCardCell.delegate = viewController

                if let eateries = eateries, eateries.count > 2 {
                    eateriesCardCell.configure(eateries)
                } else if let fallbackEateries = fallbackEateries, fallbackEateries.count > 2 {
                    eateriesCardCell.configureWithFallbackEateries(fallbackEateries)
                } else {
                    eateriesCardCell.configureForNoResults()
                }

                return eateriesCardCell
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
}
