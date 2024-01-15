//
//  EateriesCarouselTableViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol EateriesCarouselCardCellDelegate: AnyObject {
    func eateriesCardCell(didSelectEatery eatery: Eatable)
    func eateriesCardCellDidTapInfoButtonForEateryType(_ type: EateryType)
}

final class EateriesCarouselTableViewCell: UITableViewCell {
    
    static let defaultHeight: CGFloat = 300
    private let titleLabel = CardLabel(textStyle: .title1, text: "Top Eateries")
    private let carouselCollectionViewDataSource = EateriesCarouselDataSource()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("info.circle.fill")
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        button.pointerStyleProvider = buttonProvider
        return button
    }()

    private lazy var carouselCollectionView: CarouselCollectionView = {
        let collectionView = CarouselCollectionView(deviceSize: UIDevice().deviceSize, isIpad: UIDevice.current.userInterfaceIdiom == .pad)
        collectionView.delegate = self
        collectionView.dataSource = carouselCollectionViewDataSource
        return collectionView
    }()
    
    weak var delegate: EateriesCarouselCardCellDelegate?
    var eateries: [Eatable]? {
        didSet {
            if let eateries = eateries, eateries.count >= 3 {
                isHidden = false
                // display content only if we've made another API call, otherwise do nothing
                if oldValue?.count == 0 || eateries[0].name != oldValue?[0].name {
                    carouselCollectionViewDataSource.eateries = eateries
                    carouselCollectionViewDataSource.loadingState = .results
                    carouselCollectionView.reloadData()
                }
            } else { // before response from API or error
                isHidden = true
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)
        contentView.addSubview(carouselCollectionView)
        
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
        
        carouselCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLoading() {
        carouselCollectionViewDataSource.loadingState = .loading
        carouselCollectionView.reloadData()
    }
    
    func configureError() {
        carouselCollectionViewDataSource.loadingState = .error
        carouselCollectionView.reloadData()
    }
    
    // MARK: - Button selector methods

    @objc
    private func infoButtonTapped() {
        guard let type = eateries?[0].type else {
            return
        }
        delegate?.eateriesCardCellDidTapInfoButtonForEateryType(type)
    }
}

extension EateriesCarouselTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EateriesCarouselCardCell, let place = cell.place else {
            return
        }

        delegate?.eateriesCardCell(didSelectEatery: place)
    }
}
