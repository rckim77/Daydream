//
//  SightsCarouselTableViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol SightsCarouselCardCellDelegate: AnyObject {
    func sightsCardCell(didSelectPlace place: Place)
}

final class SightsCarouselTableViewCell: UITableViewCell {
    
    static let defaultHeight: CGFloat = 300
    private let titleLabel = CardLabel(textStyle: .title1, text: "Top Sights")
    private let carouselCollectionViewDataSource = SightsCarouselDataSource()
    
    private lazy var carouselCollectionView: SightsCarouselCollectionView = {
        let collectionView = SightsCarouselCollectionView(deviceSize: UIDevice().deviceSize, isIpad: UIDevice.current.userInterfaceIdiom == .pad)
        collectionView.delegate = self
        collectionView.dataSource = carouselCollectionViewDataSource
        return collectionView
    }()
    
    weak var delegate: SightsCarouselCardCellDelegate?
    var sights: [Place]? {
        didSet {
            if let sights = sights, sights.count >= 3 {
                isHidden = false
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update comparison with placeId
                if oldValue?.count == 0 || sights[0].placeId != oldValue?[0].placeId {
                    carouselCollectionViewDataSource.sights = sights
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
        contentView.addSubview(carouselCollectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(16)
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
        
    }
    
    func configureError() {
        
    }
}

extension SightsCarouselTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SightsCarouselCardCell, let place = cell.place else {
            return
        }

        delegate?.sightsCardCell(didSelectPlace: place)
    }
}
