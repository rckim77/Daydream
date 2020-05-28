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
import SnapKit

protocol SightsCardCellDelegate: AnyObject {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Placeable)
}

class SightsCardCell: UITableViewCell {

    @IBOutlet weak var pointOfInterest1View: UIView!
    private lazy var pointOfInterest1Label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    @IBOutlet weak var pointOfInterest1ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest2View: UIView!
    private lazy var pointOfInterest2Label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    @IBOutlet weak var pointOfInterest2ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest3View: UIView!
    private lazy var pointOfInterest3Label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    @IBOutlet weak var pointOfInterest3ImageView: UIImageView!
    
    weak var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [Placeable]? {
        didSet {
            if let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3 {
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if oldValue?.count == 0 || pointsOfInterest[0].placeableId != oldValue?[0].placeableId {
                    isHidden = false

                    pointOfInterest1Label.text = pointsOfInterest[0].placeableName
                    pointOfInterest2Label.text = pointsOfInterest[1].placeableName
                    pointOfInterest3Label.text = pointsOfInterest[2].placeableName

                    // reset image (to prevent background images being reused due to dequeueing reusable cells)
                    pointOfInterest1ImageView.image = nil
                    pointOfInterest2ImageView.image = nil
                    pointOfInterest3ImageView.image = nil

                    loadBackgroundImage(for: 1, with: pointsOfInterest[0])
                    loadBackgroundImage(for: 2, with: pointsOfInterest[1])
                    loadBackgroundImage(for: 3, with: pointsOfInterest[2])
                }
            } else { // before response from API or error
                isHidden = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

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

        pointOfInterest1View.addTopRoundedCorners()
        pointOfInterest2View.layer.masksToBounds = true
        pointOfInterest3View.addBottomRoundedCorners()

        // Add programmatic labels to views

        pointOfInterest1View.addSubview(pointOfInterest1Label)
        pointOfInterest1Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        pointOfInterest2View.addSubview(pointOfInterest2Label)
        pointOfInterest2Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        pointOfInterest3View.addSubview(pointOfInterest3Label)
        pointOfInterest3Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    // Note: On iOS 13, setNeedsLayout() is called first before UIViews are
    // added as subviews so we can't update UIViews just yet.
    private func updateCellLayout() {
        pointOfInterest1View.addTopRoundedCorners()
        pointOfInterest2View.layer.masksToBounds = true
        pointOfInterest3View.addBottomRoundedCorners()

        layoutIfNeeded()
    }

    @objc
    private func handleTapGesture(withSender sender: UITapGestureRecognizer) {
        guard let pointsOfInterest = pointsOfInterest else {
            return
        }

        var pointOfInterest = pointsOfInterest[0]

        if sender.view  == pointOfInterest1View {
            pointOfInterest = pointsOfInterest[0]
        } else if sender.view == pointOfInterest2View {
            pointOfInterest = pointsOfInterest[1]
        } else if sender.view == pointOfInterest3View {
            pointOfInterest = pointsOfInterest[2]
        }

        delegate?.sightsCardCell(self, didSelectPlace: pointOfInterest)
    }

    private func loadBackgroundImage(for button: Int, with pointOfInterest: Placeable) {
        guard let placeId = pointOfInterest.placeableId else {
            return
        }
        NetworkService().loadPhoto(with: placeId, success: { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            var imageView = UIImageView()

            switch button {
            case 1:
                imageView = strongSelf.pointOfInterest1ImageView
            case 2:
                imageView = strongSelf.pointOfInterest2ImageView
            case 3:
                imageView = strongSelf.pointOfInterest3ImageView
            default:
                break
            }

            strongSelf.updateCellLayout()
            strongSelf.fadeInImage(image, forImageView: imageView)
        }, failure: { [weak self] error in
            self?.logErrorEvent(error)
        })
    }
}

extension SightsCardCell: ImageViewFadeable, Loggable {}
