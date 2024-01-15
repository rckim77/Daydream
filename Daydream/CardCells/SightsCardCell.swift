//
//  SightsCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/3/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import SnapKit

protocol SightsCardCellDelegate: AnyObject {
    func sightsCardCell(_ cell: SightsCardCell, didSelectPlace place: Place)
    func sightsCardCellDidTapBusinessStatusButton(_ businessStatus: PlaceBusinessStatus)
    func sightsCardCellDidTapRetry()
}

protocol SightsCarouselCardCellDelegate: AnyObject {
    func sightsCardCell(didSelectPlace place: Place)
}

final class SightsCardCell: UITableViewCell {

    static let defaultHeight: CGFloat = 600
    private let defaultSectionHeight: CGFloat = 515
    static let errorHeight: CGFloat = 185
    private let errorSectionHeight: CGFloat = 100

    private let titleLabel = CardLabel(textStyle: .title1, text: "Top Sights")
    private lazy var sightsSectionView: UIView = {
        let view = UIView()
        view.addRoundedCorners(radius: 16)
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
        button.pointerStyleProvider = buttonProvider
        return button
    }()
    
    weak var delegate: SightsCardCellDelegate?
    var sights: [Place]? {
        didSet {
            if let sights = sights, sights.count >= 3 {
                isHidden = false
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if oldValue?.count == 0 || sights[0].placeId != oldValue?[0].placeId {
                    configure(sights)
                }
            } else { // before response from API or error
                isHidden = true
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessibilityIdentifier = "sightsCell"
        backgroundColor = .clear
        selectionStyle = .none
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    private func configure(_ sights: [Place]) {
        errorButton.isHidden = true
        sendSubviewToBack(errorButton)
        sightsSectionView.snp.updateConstraints { make in
            make.height.equalTo(defaultSectionHeight)
        }
        layoutIfNeeded()
        sight1View.configure(sight: sights[0])
        sight2View.configure(sight: sights[1])
        sight3View.configure(sight: sights[2])
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
        guard let sight = sights?[layoutType.rawValue] else {
            return
        }
        delegate?.sightsCardCell(self, didSelectPlace: sight)
    }
}

extension SightsCardCell: ImageViewFadeable {}
