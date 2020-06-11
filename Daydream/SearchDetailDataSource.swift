//
//  SearchDetailDataSource.swift
//  Daydream
//
//  Created by Raymond Kim on 4/10/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit

class SearchDetailDataSource: NSObject, UITableViewDataSource {

    enum LoadingState {
        case uninitiated, loading, results, error
    }

    var place: Place
    var pointsOfInterest: [Place]?
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
    var loadingState: LoadingState = .uninitiated

    private let networkService = NetworkService()
    let mapCardCellHeight: CGFloat = 186
    let mapCardCellIndexPath = IndexPath(row: 0, section: 0)
    var sightsCardCellHeight: CGFloat {
        return loadingState == .error ? SightsCardCell.errorHeight: SightsCardCell.defaultHeight
    }
    var eateriesCardCellHeight: CGFloat {
        return loadingState == .error ? EateriesCardCell.errorHeight: EateriesCardCell.defaultHeight
    }
    let sightsCardCellIndexPath = IndexPath(row: 1, section: 0)
    let eateriesCardCellIndexPath = IndexPath(row: 2, section: 0)

    init(place: Place) {
        self.place = place
    }

    func loadPhoto(success: @escaping(_ image: UIImage) -> Void, failure: @escaping(_ error: Error?) -> Void) {
        networkService.loadPhoto(placeId: place.placeId, completion: { result in
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
                strongSelf.loadingState = .results

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
                            strongSelf.loadingState = .error
                            failure(error)
                        }
                    })
                }
            case .failure(let error):
                strongSelf.loadingState = .error
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

            switch loadingState {
            case .loading:
                sightsCardCell.configureLoading()
            case .results:
                sightsCardCell.pointsOfInterest = pointsOfInterest
            case .error:
                sightsCardCell.configureError()
            case .uninitiated:
                return sightsCardCell
            }

            return sightsCardCell
        case eateriesCardCellIndexPath:
            guard let eateriesCardCell = tableView.dequeueReusableCell(withIdentifier: "eateriesCardCell", for: indexPath) as? EateriesCardCell else {
                return UITableViewCell()
            }

            eateriesCardCell.delegate = viewController

            if loadingState == .loading {
                eateriesCardCell.configureLoading()
            } else if loadingState == .error {
                eateriesCardCell.configureError()
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
