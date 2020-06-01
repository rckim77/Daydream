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

    private lazy var visualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds
        return visualEffectView
    }()

    @IBOutlet weak var pointOfInterest1View: UIView!
    private let pointOfInterest1GradientView = GradientView()
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
    private lazy var pointOfInterest1LoadingView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return visualEffectView
    }()
    private lazy var pointOfInterest1ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    @IBOutlet weak var pointOfInterest2View: UIView!
    private let pointOfInterest2GradientView = GradientView()
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
    private lazy var pointOfInterest2LoadingView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return visualEffectView
    }()
    private lazy var pointOfInterest2ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    @IBOutlet weak var pointOfInterest3View: UIView!
    private let pointOfInterest3GradientView = GradientView()
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
    private lazy var pointOfInterest3LoadingView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return visualEffectView
    }()
    private lazy var pointOfInterest3ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
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

    // swiftlint:disable function_body_length
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

        pointOfInterest1View.addSubview(pointOfInterest1LoadingView)
        pointOfInterest1View.addSubview(pointOfInterest1ImageView)
        pointOfInterest1View.addSubview(pointOfInterest1GradientView)
        pointOfInterest1View.addSubview(pointOfInterest1Label)
        pointOfInterest1View.addSubview(pointOfInterest1BusinessStatusButton)
        pointOfInterest2View.addSubview(pointOfInterest2LoadingView)
        pointOfInterest2View.addSubview(pointOfInterest2ImageView)
        pointOfInterest2View.addSubview(pointOfInterest2GradientView)
        pointOfInterest2View.addSubview(pointOfInterest2Label)
        pointOfInterest2View.addSubview(pointOfInterest2BusinessStatusButton)
        pointOfInterest3View.addSubview(pointOfInterest3LoadingView)
        pointOfInterest3View.addSubview(pointOfInterest3ImageView)
        pointOfInterest3View.addSubview(pointOfInterest3GradientView)
        pointOfInterest3View.addSubview(pointOfInterest3Label)
        pointOfInterest3View.addSubview(pointOfInterest3BusinessStatusButton)

        pointOfInterest1LoadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest1ImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest1Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest1BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest1Label.snp.leading)
        }
        pointOfInterest1GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
        pointOfInterest2LoadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest2ImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest2Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest2BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest2Label.snp.leading)
        }
        pointOfInterest2GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
        pointOfInterest3LoadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest3ImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pointOfInterest3Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        pointOfInterest3BusinessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(pointOfInterest3Label.snp.leading)
        }
        pointOfInterest3GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    // Note: On iOS 13, setNeedsLayout() is called first before UIViews are
    // added as subviews so we can't update UIViews just yet.
    private func updateCellLayout() {
        pointOfInterest1View.addTopRoundedCorners()
        pointOfInterest2View.layer.masksToBounds = true
        pointOfInterest3View.addBottomRoundedCorners()

        pointOfInterest1GradientView.gradientLayer.frame = pointOfInterest1GradientView.bounds
        pointOfInterest2GradientView.gradientLayer.frame = pointOfInterest2GradientView.bounds
        pointOfInterest3GradientView.gradientLayer.frame = pointOfInterest3GradientView.bounds

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

    // MARK: - Networking methods

    private func loadBackgroundImage(forButton button: Int, with pointOfInterest: Placeable) {
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

    // MARK: - Configuration methods

    func configureLoading() {
        [pointOfInterest1ImageView, pointOfInterest2ImageView, pointOfInterest3ImageView].forEach { imageView in
            imageView.image = nil
        }

        [pointOfInterest1Label, pointOfInterest2Label, pointOfInterest3Label].enumerated().forEach { (index, label) in
            label.text = "Loading..."
        }
    }

    private func configure(_ pointsOfInterest: [Placeable]) {
        isHidden = false

        [pointOfInterest1Label, pointOfInterest2Label, pointOfInterest3Label].enumerated().forEach { (index, label) in
            label.text = pointsOfInterest[index].placeableName
        }

        [pointOfInterest1BusinessStatusButton,
         pointOfInterest2BusinessStatusButton,
         pointOfInterest3BusinessStatusButton].enumerated().forEach { (index, button) in
            let businessStatus = pointsOfInterest[index].placeableBusinessStatus
            button.configureWithSystemIcon(businessStatus?.imageName ?? "")
            button.tintColor = businessStatus?.displayColor
            button.isHidden = businessStatus == .operational
        }

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        [pointOfInterest1ImageView, pointOfInterest2ImageView, pointOfInterest3ImageView].forEach { imageView in
            imageView?.image = nil
        }

        pointsOfInterest.enumerated().forEach { (index, pointOfInterest) in
            loadBackgroundImage(forButton: index + 1, with: pointOfInterest)
        }
    }

    // MARK: - Button selector methods

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
