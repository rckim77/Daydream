//
//  EateriesCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/3/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import SnapKit

protocol EateriesCardCellDelegate: AnyObject {
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectEatery eatery: Eatable)
    func eateriesCardCellDidTapInfoButtonForEateryType(_ type: EateryType)
    func eateriesCardCellDidTapRetry()
}

final class EateriesCardCell: UITableViewCell {

    static let defaultHeight: CGFloat = 600
    private let defaultSectionHeight: CGFloat = 515
    static let errorHeight: CGFloat = 185
    private let errorSectionHeight: CGFloat = 100

    private let titleLabel = CardLabel(textStyle: .title1, text: "Top Eateries")
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("info.circle.fill")
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()
    private lazy var eateriesSectionView: UIView = {
        let view = UIView()
        view.addRoundedCorners(radius: 8)
        return view
    }()
    private lazy var eatery1View: EateryView = {
        let view = EateryView(layoutType: .top, delegate: self)
        return view
    }()
    private lazy var eatery2View: EateryView = {
        let view = EateryView(layoutType: .middle, delegate: self)
        return view
    }()
    private lazy var eatery3View: EateryView = {
        let view = EateryView(layoutType: .bottom, delegate: self)
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

    weak var delegate: EateriesCardCellDelegate?
    var eateries: [Eatable]? {
        didSet {
            if let eateries = eateries, eateries.count >= 3 {
                isHidden = false
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if oldValue?.count == 0 || eateries[0].name != oldValue?[0].name {
                    configure(eateries)
                }
            } else { // before response from API or error
                isHidden = true
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(errorButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)
        contentView.addSubview(eateriesSectionView)
        eateriesSectionView.addSubview(eatery1View)
        eateriesSectionView.addSubview(eatery2View)
        eateriesSectionView.addSubview(eatery3View)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }

        infoButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }

        eateriesSectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(515)
        }

        eatery1View.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(eatery2View)
        }

        eatery2View.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(eatery1View.snp.bottom)
            make.height.equalTo(eatery3View)
        }

        eatery3View.snp.makeConstraints { make in
            make.top.equalTo(eatery2View.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(eatery1View)
        }

        errorButton.snp.makeConstraints { make in
            make.top.equalTo(eatery1View.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(eatery3View.snp.bottom)
        }

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        eatery1View.resetBackgroundImage()
        eatery2View.resetBackgroundImage()
        eatery3View.resetBackgroundImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration methods

    func configureLoading() {
        errorButton.isHidden = true
        sendSubviewToBack(errorButton)
        eateriesSectionView.snp.updateConstraints { make in
            make.height.equalTo(defaultSectionHeight)
        }
        layoutIfNeeded()
        eatery1View.configureLoading()
        eatery2View.configureLoading()
        eatery3View.configureLoading()
    }

    func configureError() {
        errorButton.isHidden = false
        contentView.bringSubviewToFront(errorButton)
        eateriesSectionView.snp.updateConstraints { make in
            make.height.equalTo(errorSectionHeight)
        }
        layoutIfNeeded()
        eatery1View.configureError()
        eatery2View.configureError()
        eatery3View.configureError()
    }

    func configure(_ eateries: [Eatable]) {
        errorButton.isHidden = true
        sendSubviewToBack(errorButton)
        self.eateries = eateries
        eateriesSectionView.snp.updateConstraints { make in
            make.height.equalTo(defaultSectionHeight)
        }
        layoutIfNeeded()
        eatery1View.configure(eatery: eateries[0])
        eatery2View.configure(eatery: eateries[1])
        eatery3View.configure(eatery: eateries[2])
    }

    // MARK: - Button selector methods

    @objc
    private func infoButtonTapped() {
        guard let type = eateries?[0].type else {
            return
        }
        delegate?.eateriesCardCellDidTapInfoButtonForEateryType(type)
    }

    @objc
    private func retryButtonTapped() {
        delegate?.eateriesCardCellDidTapRetry()
    }
}

extension EateriesCardCell: EateryViewDelegate {
    func eateryViewDidTapEatery(layoutType: EateryView.LayoutType) {
        guard let eatery = eateries?[layoutType.rawValue] else {
            return
        }
        delegate?.eateriesCardCell(self, didSelectEatery: eatery)
    }
}

extension EateriesCardCell: ImageViewFadeable {}
