//
//  CuratedCityCollectionViewCell.swift
//  Daydream
//
//  Created by Ray Kim on 7/13/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import GooglePlacesSwift

final class CuratedCityCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let textStyle: UIFont.TextStyle = UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .body
        label.font = .preferredFont(forTextStyle: textStyle)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let gradientView = GradientView()
    
    static let reuseIdentifier = "curatedCitiesCollectionViewCell"

    private var imageSet = false
    private var titleLabelPadding: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
    }

    var place: Place?
    var placeImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addRoundedCorners(radius: 16)
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.75)
        contentView.addSubview(imageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(titleLabelPadding)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String) {
        titleLabel.text = name
        
        // prevent image flickering and extra network calls
        guard !imageSet else {
            return
        }
        imageSet = true
        Task {
            do {
                let result = try await API.PlaceSearch.fetchPlaceAndImageBy(name: name)
                place = result.0
                placeImage = result.1
                
                await MainActor.run {
                    fadeInImage(result.1, forImageView: imageView)
                    gradientView.updateFrame()
                }
            } catch {}
        }
    }
}

extension CuratedCityCollectionViewCell: ImageViewFadeable {}
