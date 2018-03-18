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
    var pointsOfInterest: [JSON]? {
        didSet {
            guard let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3 else {
                return
            }

            let pointOfInterest1 = pointsOfInterest[0]
            let pointOfInterest2 = pointsOfInterest[1]
            let pointOfInterest3 = pointsOfInterest[2]

            pointOfInterest1Btn.setTitle(pointOfInterest1.dictionaryValue["name"]?.stringValue, for: .normal)
            pointOfInterest2Btn.setTitle(pointOfInterest2.dictionaryValue["name"]?.stringValue, for: .normal)
            pointOfInterest3Btn.setTitle(pointOfInterest3.dictionaryValue["name"]?.stringValue, for: .normal)

            loadBackgroundImage(for: 1, with: pointOfInterest1)
            loadBackgroundImage(for: 2, with: pointOfInterest2)
            loadBackgroundImage(for: 3, with: pointOfInterest3)
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

    private func getViewport(for pointOfInterest: JSON) -> GMSCoordinateBounds? {
        let viewportRaw = pointOfInterest["geometry"]["viewport"]
        let northeastRaw = viewportRaw["northeast"]
        let southwestRaw = viewportRaw["southwest"]
        let northeast = CLLocationCoordinate2D(latitude: northeastRaw["lat"].doubleValue, longitude: northeastRaw["lng"].doubleValue)
        let southwest = CLLocationCoordinate2D(latitude: southwestRaw["lat"].doubleValue, longitude: southwestRaw["lng"].doubleValue)

        return GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
    }

    private func loadBackgroundImage(for button: Int, with pointOfInterest: JSON) {
        let placeId = pointOfInterest["place_id"].stringValue

        loadPhotoForPlace(placeId: placeId, completion: { [weak self] image in
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
