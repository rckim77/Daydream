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
    func didSelectPointOfInterest(with place: PointOfInterest)
}

class SightsCardCell: UITableViewCell {

    @IBOutlet weak var pointOfInterest1View: UIView!
    @IBOutlet weak var pointOfInterest1Label: UILabel!
    @IBOutlet weak var pointOfInterest1ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest2View: UIView!
    @IBOutlet weak var pointOfInterest2Label: UILabel!
    @IBOutlet weak var pointOfInterest2ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest3View: UIView!
    @IBOutlet weak var pointOfInterest3Label: UILabel!
    @IBOutlet weak var pointOfInterest3ImageView: UIImageView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    weak var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [PointOfInterest]? {
        didSet {
            if let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3, oldValue?.count != 0 {
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if pointsOfInterest[0].placeId != oldValue?[0].placeId {
                    toggleViews([pointOfInterest1View, pointOfInterest2View, pointOfInterest3View], willHide: false)

                    pointOfInterest1Label.text = pointsOfInterest[0].name
                    pointOfInterest2Label.text = pointsOfInterest[1].name
                    pointOfInterest3Label.text = pointsOfInterest[2].name

                    // reset image (to prevent background images being reused due to dequeueing reusable cells)
                    pointOfInterest1ImageView.image = nil
                    pointOfInterest2ImageView.image = nil
                    pointOfInterest3ImageView.image = nil

                    loadBackgroundImage(for: 1, with: pointsOfInterest[0])
                    loadBackgroundImage(for: 2, with: pointsOfInterest[1])
                    loadBackgroundImage(for: 3, with: pointsOfInterest[2])
                }
            } else { // before response from API or error
                toggleViews([pointOfInterest1View, pointOfInterest2View, pointOfInterest3View], willHide: true)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        pointOfInterest1View.addTopRoundedCorners()
        pointOfInterest2View.layer.masksToBounds = true
        pointOfInterest3View.addBottomRoundedCorners()

        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        pointOfInterest1View.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        pointOfInterest2View.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        pointOfInterest3View.addGestureRecognizer(tapGesture3)

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        pointOfInterest1ImageView.image = nil
        pointOfInterest2ImageView.image = nil
        pointOfInterest3ImageView.image = nil
    }

    @objc
    private func handleTapGesture(withSender sender: UITapGestureRecognizer) {
        guard let pointsOfInterest = pointsOfInterest else { return }

        var pointOfInterest = pointsOfInterest[0]

        if sender.view  == pointOfInterest1View {
            pointOfInterest = pointsOfInterest[0]
        } else if sender.view == pointOfInterest2View {
            pointOfInterest = pointsOfInterest[1]
        } else if sender.view == pointOfInterest3View {
            pointOfInterest = pointsOfInterest[2]
        }

        delegate?.didSelectPointOfInterest(with: pointOfInterest)
    }

    private func getViewport(for pointOfInterest: PointOfInterest) -> GMSCoordinateBounds? {
        let viewport = pointOfInterest.viewport
        let northeast = CLLocationCoordinate2D(latitude: viewport.northeastLat, longitude: viewport.northeastLng)
        let southwest = CLLocationCoordinate2D(latitude: viewport.southeastLat, longitude: viewport.southeastLng)

        return GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
    }

    private func loadBackgroundImage(for button: Int, with pointOfInterest: PointOfInterest) {
        NetworkService().loadPhoto(with: pointOfInterest.placeId, success: { [weak self] image in
            guard let strongSelf = self else { return }

            if button == 1 {
                strongSelf.pointOfInterest1ImageView.image = image
            } else if button == 2 {
                strongSelf.pointOfInterest2ImageView.image = image
            } else if button == 3 {
                strongSelf.pointOfInterest3ImageView.image = image
            }
            
        }, failure: { error in
            print(error)
        })
    }

    private func toggleViews(_ views: [UIView], willHide: Bool) {
        noContentLabel.isHidden = !willHide

        for view in views {
            view.isHidden = willHide
        }
    }
}
