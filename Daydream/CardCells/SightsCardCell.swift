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
    func sightsCardCellDidTapBusinessStatusButton(_ businessStatus: PlaceBusinessStatus)
}

class SightsCardCell: UITableViewCell {

    @IBOutlet weak var pointOfInterest1View: UIView!
    private let pointOfInterest1Label = CardLabel()
    private lazy var pointOfInterest1BusinessStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.addShadow(opacity: 0.8, offset: CGSize(width: 0, height: 1))
        button.addTarget(self, action: #selector(pointOfInterest1BusinessStatusButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()
    @IBOutlet weak var pointOfInterest1ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest2View: UIView!
    private let pointOfInterest2Label = CardLabel()
    private lazy var pointOfInterest2BusinessStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.addShadow(opacity: 0.8, offset: CGSize(width: 0, height: 1))
        button.addTarget(self, action: #selector(pointOfInterest2BusinessStatusButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()
    @IBOutlet weak var pointOfInterest2ImageView: UIImageView!
    @IBOutlet weak var pointOfInterest3View: UIView!
    private let pointOfInterest3Label = CardLabel()
    private lazy var pointOfInterest3BusinessStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.addShadow(opacity: 0.8, offset: CGSize(width: 0, height: 1))
        button.addTarget(self, action: #selector(pointOfInterest3BusinessStatusButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()
    @IBOutlet weak var pointOfInterest3ImageView: UIImageView!
    
    weak var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [Placeable]? {
        didSet {
            if let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3 {
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if oldValue?.count == 0 || pointsOfInterest[0].placeableId != oldValue?[0].placeableId {
                    configure(pointsOfInterest)
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
        pointOfInterest1View.addSubview(pointOfInterest1BusinessStatusButton)
        pointOfInterest2View.addSubview(pointOfInterest2Label)
        pointOfInterest2View.addSubview(pointOfInterest2BusinessStatusButton)
        pointOfInterest3View.addSubview(pointOfInterest3Label)
        pointOfInterest3View.addSubview(pointOfInterest3BusinessStatusButton)

        pointOfInterest1Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest1BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest1Label.snp.leading)
        }
        pointOfInterest2Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest2BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest2Label.snp.leading)
        }
        pointOfInterest3Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest3BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest3Label.snp.leading)
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

    private func configure(_ pointsOfInterest: [Placeable]) {
        isHidden = false

        pointOfInterest1Label.text = pointsOfInterest[0].placeableName
        pointOfInterest1BusinessStatusButton.configureWithSystemIcon(pointsOfInterest[0].placeableBusinessStatus?.imageName ?? "")
        pointOfInterest1BusinessStatusButton.tintColor = pointsOfInterest[0].placeableBusinessStatus?.displayColor
        pointOfInterest1BusinessStatusButton.isHidden = pointsOfInterest[0].placeableBusinessStatus == .operational
        pointOfInterest2Label.text = pointsOfInterest[1].placeableName
        pointOfInterest2BusinessStatusButton.configureWithSystemIcon(pointsOfInterest[1].placeableBusinessStatus?.imageName ?? "")
        pointOfInterest2BusinessStatusButton.tintColor = pointsOfInterest[1].placeableBusinessStatus?.displayColor
        pointOfInterest2BusinessStatusButton.isHidden = pointsOfInterest[1].placeableBusinessStatus == .operational
        pointOfInterest3Label.text = pointsOfInterest[2].placeableName
        pointOfInterest3BusinessStatusButton.configureWithSystemIcon(pointsOfInterest[2].placeableBusinessStatus?.imageName ?? "")
        pointOfInterest3BusinessStatusButton.tintColor = pointsOfInterest[2].placeableBusinessStatus?.displayColor
        pointOfInterest3BusinessStatusButton.isHidden = pointsOfInterest[2].placeableBusinessStatus == .operational

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        pointOfInterest1ImageView.image = nil
        pointOfInterest2ImageView.image = nil
        pointOfInterest3ImageView.image = nil

        loadBackgroundImage(for: 1, with: pointsOfInterest[0])
        loadBackgroundImage(for: 2, with: pointsOfInterest[1])
        loadBackgroundImage(for: 3, with: pointsOfInterest[2])
    }

    @objc
    private func pointOfInterest1BusinessStatusButtonTapped() {
        guard let businessStatus = pointsOfInterest?[0].placeableBusinessStatus else {
            return
        }
        delegate?.sightsCardCellDidTapBusinessStatusButton(businessStatus)
    }

    @objc
    private func pointOfInterest2BusinessStatusButtonTapped() {
        guard let businessStatus = pointsOfInterest?[1].placeableBusinessStatus else {
            return
        }
        delegate?.sightsCardCellDidTapBusinessStatusButton(businessStatus)
    }

    @objc
    private func pointOfInterest3BusinessStatusButtonTapped() {
        guard let businessStatus = pointsOfInterest?[2].placeableBusinessStatus else {
            return
        }
        delegate?.sightsCardCellDidTapBusinessStatusButton(businessStatus)
    }
}

extension SightsCardCell: ImageViewFadeable, Loggable {}
