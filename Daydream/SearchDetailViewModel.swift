//
//  SearchDetailViewModel.swift
//  Daydream
//
//  Created by Raymond Kim on 4/10/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

class SearchDetailDataSource: NSObject, UITableViewDataSource {

    var place: Placeable
    var pointsOfInterest: [Placeable]
    var eateries: [Eatery]?
    weak var viewController: SearchDetailViewController?
    lazy var arrayModels: [Any]? = {
        var array = [Any]()

        array.append(place)
        array.append(pointsOfInterest)

        if let eateries = eateries {
            array.append(eateries)
        }

        return array
    }()

    let networkService = NetworkService()
    let summaryCardCellHeight: CGFloat = 190
    let mapCardCellHeight: CGFloat = 190
    let mapCardCellIndexPath = IndexPath(row: 0, section: 0)
    let sightsCardCellHeight: CGFloat = 600
    let sightsCardCellIndexPath = IndexPath(row: 1, section: 0)
    let eateriesCardCellIndexPath = IndexPath(row: 2, section: 0)

    init(place: Placeable, pointsOfInterest: [Placeable]) {
        self.place = place
        self.pointsOfInterest = pointsOfInterest
    }

    func loadPhoto(success: @escaping(_ image: UIImage) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadPhoto(with: place.placeableId, success: { photo in
            success(photo)
        }, failure: { error in
            failure(error)
        })
    }

    func loadPointsOfInterest(failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadTopSights(with: place, success: { [weak self] topSights in
            guard let strongSelf = self else {
                failure(nil)
                return
            }

            strongSelf.pointsOfInterest = topSights
        }, failure: { error in
            failure(error)
        })
    }

    func loadTopEateries(success: @escaping() -> Void, failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadTopEateries(with: place, success: { [weak self] eateries in
            guard let strongSelf = self else {
                failure(nil)
                return
            }

            strongSelf.eateries = eateries
            success()
        }, failure: { error in
            failure(error)
        })
    }

    // MARK: - UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayModels?.count ?? 0
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
                eateriesCardCell.eateries = eateries

                return eateriesCardCell
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
}
