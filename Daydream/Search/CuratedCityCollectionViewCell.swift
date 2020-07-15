//
//  CuratedCityCollectionViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 7/13/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

final class CuratedCityCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .white
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    static let reuseIdentifier = "curatedCitiesCollectionViewCell"
    
    private var cancellable: AnyCancellable?
    private var imageSet = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addRoundedCorners(radius: 8)
        contentView.backgroundColor = .lightGray
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String) {
        titleLabel.text = name
        
        // prevent cancellable being set unnecessarily
        guard !imageSet else {
            return
        }
        imageSet = true
        
        cancellable = API.PlaceSearch.loadPlace(name: name, queryType: .placeByName)?
            .tryMap { place -> String in
                guard let photoRef = place.photoRef else {
                    throw NetworkError.noImage
                }
                return photoRef
            }
            .compactMap { // strips nil
                API.PlaceSearch.loadGooglePhoto(photoRef: $0, maxHeight: Int(UIScreen.main.bounds.height))
            }
            .flatMap { $0 } // converts into correct publisher so sink works
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                print("== received value")
                self?.imageView.image = image
            })
        
    }
}
