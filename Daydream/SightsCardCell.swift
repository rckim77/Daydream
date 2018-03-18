//
//  SightsCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/3/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces

protocol SightsCardCellDelegate: class {
    func didSelectPointOfInterest(with viewport: GMSCoordinateBounds)
}

class SightsCardCell: UITableViewCell {

    @IBOutlet weak var pointOfInterest1Btn: UIButton!
    @IBOutlet weak var pointOfInterest2Btn: UIButton!
    @IBOutlet weak var pointOfInterest3Btn: UIButton!

    weak var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [PointOfInterest]? {
        didSet {
            // POSTLAUNCH: - Update comparison with placeId
            if let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3, pointsOfInterest[0].placeId != oldValue?[0].placeId {

                let pointOfInterest1 = pointsOfInterest[0]
                let pointOfInterest2 = pointsOfInterest[1]
                let pointOfInterest3 = pointsOfInterest[2]

                pointOfInterest1Btn.setTitle(pointOfInterest1.name, for: .normal)
                pointOfInterest2Btn.setTitle(pointOfInterest2.name, for: .normal)
                pointOfInterest3Btn.setTitle(pointOfInterest3.name, for: .normal)

                loadBackgroundImage(for: 1, with: pointOfInterest1)
                loadBackgroundImage(for: 2, with: pointOfInterest2)
                loadBackgroundImage(for: 3, with: pointOfInterest3)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        pointOfInterest1Btn.addTopRoundedCorners()
        pointOfInterest3Btn.addBottomRoundedCorners()

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        pointOfInterest1Btn.setBackgroundImage(nil, for: .normal)
        pointOfInterest2Btn.setBackgroundImage(nil, for: .normal)
        pointOfInterest3Btn.setBackgroundImage(nil, for: .normal)
    }

    @IBAction func pointOfInterest1BtnTapped(_ sender: UIButton) {
        guard let pointsOfInterest = pointsOfInterest, let viewport = getViewport(for: pointsOfInterest[0]) else { return }

        delegate?.didSelectPointOfInterest(with: viewport)
    }

    @IBAction func pointOfInterest2BtnTapped(_ sender: UIButton) {
        guard let pointsOfInterest = pointsOfInterest, let viewport = getViewport(for: pointsOfInterest[1]) else { return }

        delegate?.didSelectPointOfInterest(with: viewport)
    }

    @IBAction func pointOfInterest3BtnTapped(_ sender: UIButton) {
        guard let pointsOfInterest = pointsOfInterest, let viewport = getViewport(for: pointsOfInterest[2]) else { return }

        delegate?.didSelectPointOfInterest(with: viewport)
    }

    private func getViewport(for pointOfInterest: PointOfInterest) -> GMSCoordinateBounds? {
        let viewport = pointOfInterest.viewport
        let northeast = CLLocationCoordinate2D(latitude: viewport.northeastLat, longitude: viewport.northeastLng)
        let southwest = CLLocationCoordinate2D(latitude: viewport.southeastLat, longitude: viewport.southeastLng)

        return GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
    }

    private func loadBackgroundImage(for button: Int, with pointOfInterest: PointOfInterest) {
        loadPhotoForPlace(placeId: pointOfInterest.placeId, completion: { [weak self] image in
            guard let strongSelf = self else { return }

            if button == 1 {
                strongSelf.pointOfInterest1Btn.setBackgroundImage(image, for: .normal)
            } else if button == 2 {
                strongSelf.pointOfInterest2Btn.setBackgroundImage(image, for: .normal)
            } else if button == 3 {
                strongSelf.pointOfInterest3Btn.setBackgroundImage(image, for: .normal)
            }
        })
    }
}
