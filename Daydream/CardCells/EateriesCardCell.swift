//
//  EateriesCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/3/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces
import SnapKit

protocol EateriesCardCellDelegate: AnyObject {
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectEatery eatery: Eatery)
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectFallbackEatery eatery: Placeable)
    func eateriesCardCellDidTapInfoButtonForEatery()
    func eateriesCardCellDidTapInfoButtonForFallbackEatery()
}

class EateriesCardCell: UITableViewCell {
    private lazy var titleLabel = CardLabel(textStyle: .title1, text: "Top Eateries")
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

    weak var delegate: EateriesCardCellDelegate?
    private var eateries: [Eatery]?
    private var fallbackEateries: [Placeable]?

    override func awakeFromNib() {
        super.awakeFromNib()

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

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        eatery1View.resetBackgroundImage()
        eatery2View.resetBackgroundImage()
        eatery3View.resetBackgroundImage()
    }

    // MARK: - Configuration methods

    func configureLoading() {
        layoutIfNeeded()
        eatery1View.configureLoading()
        eatery2View.configureLoading()
        eatery3View.configureLoading()
    }

    func configure(_ eateries: [Eatery]) {
        self.eateries = eateries
        self.fallbackEateries = nil
        layoutIfNeeded()
        eatery1View.configure(eatery: eateries[0])
        eatery2View.configure(eatery: eateries[1])
        eatery3View.configure(eatery: eateries[2])
    }

    func configureWithFallbackEateries(_ eateries: [Placeable]) {
        self.fallbackEateries = eateries
        self.eateries = nil
        layoutIfNeeded()
        eatery1View.configureFallback(eatery: eateries[0])
        eatery2View.configureFallback(eatery: eateries[1])
        eatery3View.configureFallback(eatery: eateries[2])
    }

    // MARK: - Button selector methods

    @objc
    private func infoButtonTapped() {
        if eateries != nil {
            delegate?.eateriesCardCellDidTapInfoButtonForEatery()
        } else if fallbackEateries != nil {
            delegate?.eateriesCardCellDidTapInfoButtonForFallbackEatery()
        }
    }
}

extension EateriesCardCell: EateryViewDelegate {
    func eateryViewDidTapEatery(layoutType: EateryView.LayoutType) {
        guard let eatery = eateries?[layoutType.rawValue] else {
            return
        }
        delegate?.eateriesCardCell(self, didSelectEatery: eatery)
    }

    func eateryViewDidTapFallbackEatery(layoutType: EateryView.LayoutType) {
        guard let eatery = fallbackEateries?[layoutType.rawValue] else {
            return
        }
        delegate?.eateriesCardCell(self, didSelectFallbackEatery: eatery)
    }
}

extension EateriesCardCell: ImageViewFadeable {}
