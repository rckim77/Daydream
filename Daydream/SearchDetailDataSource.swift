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
        networkService.loadPhoto(placeId: place.placeableId, completion: { result in
            switch result {
            case .success(let image):
                success(image)
            case .failure(let error):
                failure(error)
            }
        })
    }

    func loadSightsAndEateries(success: @escaping(_ indexPaths: [IndexPath]) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadSightsAndEateries(place: place, completion: { [weak self] result in
            guard let strongSelf = self else {
                failure(nil)
                return
            }

            switch result {
            case .success(let (sights, eateries)):
                strongSelf.pointsOfInterest = sights
                strongSelf.isLoading = false

                if !eateries.isEmpty {
                    strongSelf.prevEateries = strongSelf.eateries
                    strongSelf.eateries = eateries
                    success([strongSelf.sightsCardCellIndexPath, strongSelf.eateriesCardCellIndexPath])
                } else {
                    strongSelf.networkService.loadGoogleRestaurants(place: strongSelf.place, completion: { [weak self] result in
                        guard let strongSelf = self else {
                            failure(nil)
                            return
                        }
                        switch result {
                        case .success(let restaurants):
                            strongSelf.prevEateries = strongSelf.eateries
                            strongSelf.eateries = restaurants
                            success([strongSelf.sightsCardCellIndexPath, strongSelf.eateriesCardCellIndexPath])
                        case .failure(let error):
                            failure(error)
                        }
                    })
                }
            case .failure(let error):
                failure(error)
            }
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
            } else if eateriesIsEqualToPrevious {
                // this is for when the user is simply scrolling and hasn't reloaded
                return eateriesCardCell
            } else if let eateries = eateries, eateries.count > 2, !eateriesIsEqualToPrevious {
                eateriesCardCell.configure(eateries)
                prevEateries = eateries
            }

            return eateriesCardCell
        default:
            return UITableViewCell()
        }
    }
}
