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

protocol SightsCardCellDelegate: class {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Placeable)
    func sightsCardCellDidTapBusinessStatusButton(_ businessStatus: PlaceBusinessStatus)
    func sightsCardCellDidTapRetry()
}

class SightsCardCell: UITableViewCell {

    static let defaultHeight: CGFloat = 600
    private let defaultSectionHeight: CGFloat = 515
    static let errorHeight: CGFloat = 185
    private let errorSectionHeight: CGFloat = 100

    private lazy var titleLabel = CardLabel(textStyle: .title1, text: "Top Sights")
    private lazy var sightsSectionView: UIView = {
        let view = UIView()
        view.addRoundedCorners(radius: 8)
        return view
    }()
    private lazy var sight1View: SightView = {
        let view = SightView(layoutType: .top, delegate: self)
        return view
    }()
    private lazy var sight2View: SightView = {
        let view = SightView(layoutType: .middle, delegate: self)
        return view
    }()
    private lazy var sight3View: SightView = {
        let view = SightView(layoutType: .bottom, delegate: self)
        return view
    }()
    private lazy var errorButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureForError()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()
    
    weak var delegate: SightsCardCellDelegate?
    var pointsOfInterest: [Placeable]? {
        didSet {
            if let pointsOfInterest = pointsOfInterest, pointsOfInterest.count >= 3 {
                isHidden = false
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

        contentView.addSubview(errorButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sightsSectionView)
        sightsSectionView.addSubview(sight1View)
        sightsSectionView.addSubview(sight2View)
        sightsSectionView.addSubview(sight3View)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
        }

        sightsSectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(515)
        }

        sight1View.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(sight2View)
        }

        sight2View.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(sight1View.snp.bottom)
            make.height.equalTo(sight3View)
        }

        sight3View.snp.makeConstraints { make in
            make.top.equalTo(sight2View.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(sight1View)
        }

        errorButton.snp.makeConstraints { make in
            make.top.equalTo(sight1View.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(sight3View.snp.bottom)
        }

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        sight1View.resetBackgroundImage()
        sight2View.resetBackgroundImage()
        sight3View.resetBackgroundImage()
    }

    // MARK: - Configuration methods

    func configureLoading() {
        errorButton.isHidden = true
        sendSubviewToBack(errorButton)
        sightsSectionView.snp.updateConstraints { make in
            make.height.equalTo(defaultSectionHeight)
        }
        layoutIfNeeded()
        sight1View.configureLoading()
        sight2View.configureLoading()
        sight3View.configureLoading()
    }

    func configureError() {
        errorButton.isHidden = false
        contentView.bringSubviewToFront(errorButton)
        sightsSectionView.snp.updateConstraints { make in
            make.height.equalTo(errorSectionHeight)
        }
        layoutIfNeeded()
        sight1View.configureError()
        sight2View.configureError()
        sight3View.configureError()
    }

    private func configure(_ pointsOfInterest: [Placeable]) {
        errorButton.isHidden = true
        sendSubviewToBack(errorButton)
        sightsSectionView.snp.updateConstraints { make in
            make.height.equalTo(defaultSectionHeight)
        }
        layoutIfNeeded()
        sight1View.configure(sight: pointsOfInterest[0])
        sight2View.configure(sight: pointsOfInterest[1])
        sight3View.configure(sight: pointsOfInterest[2])
    }

    // MARK: - Button selector methods

    @objc
    private func retryButtonTapped() {
        delegate?.sightsCardCellDidTapRetry()
    }
}

extension SightsCardCell: SightViewDelegate {
    func sightViewDidTapBusinessStatus(status: PlaceBusinessStatus) {
        delegate?.sightsCardCellDidTapBusinessStatusButton(status)
    }

    func sightViewDidTap(layoutType: SightView.LayoutType) {
        guard let sight = pointsOfInterest?[layoutType.rawValue] else {
            return
        }
        delegate?.sightsCardCell(self, didSelectPlace: sight)
    }
}

extension SightsCardCell: ImageViewFadeable, Loggable {}
