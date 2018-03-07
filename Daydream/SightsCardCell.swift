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

protocol SightsCardCellDelegate {
    func didSelectPointOfInterest(with viewport: GMSCoordinateBounds)
}

class SightsCardCell: UITableViewCell {

    @IBOutlet weak var pointOfInterest1Btn: UIButton!
    @IBOutlet weak var pointOfInterest2Btn: UIButton!

    var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [JSON]? {
        didSet {
            guard let pointsOfInterest = pointsOfInterest else { return }

            let pointOfInterest1 = pointsOfInterest[0].dictionaryValue["name"]?.stringValue
            let pointOfInterest2 = pointsOfInterest[1].dictionaryValue["name"]?.stringValue
            pointOfInterest1Btn.setTitle(pointOfInterest1, for: .normal)
            pointOfInterest2Btn.setTitle(pointOfInterest2, for: .normal)
        }
    }
    @IBAction func pointOfInterest1BtnTapped(_ sender: UIButton) {
        guard let pointsOfInterest = pointsOfInterest else { return }

        let viewportRaw = pointsOfInterest[0]["geometry"]["viewport"]
        let northeastRaw = viewportRaw["northeast"]
        let southwestRaw = viewportRaw["southwest"]
        let northeast = CLLocationCoordinate2D(latitude: northeastRaw["lat"].doubleValue, longitude: northeastRaw["lng"].doubleValue)
        let southwest = CLLocationCoordinate2D(latitude: southwestRaw["lat"].doubleValue, longitude: southwestRaw["lng"].doubleValue)
        let viewport = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)

        delegate?.didSelectPointOfInterest(with: viewport)
    }

    @IBAction func pointOfInterest2BtnTapped(_ sender: UIButton) {

    }

}
