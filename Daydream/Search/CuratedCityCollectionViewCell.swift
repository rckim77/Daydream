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
    
    private var cancellable: AnyCancellable?
    private var imageSet = false

    var place: Place?
    var placeImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addRoundedCorners(radius: 8)
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
            make.leading.bottom.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String) {
        titleLabel.text = name
        gradientView.updateFrame()
        
        // prevent cancellable being set unnecessarily
        guard !imageSet else {
            return
        }
        imageSet = true
        
        cancellable = API.PlaceSearch.loadPlace(name: name, queryType: .placeByName)?
            .tryMap { [weak self] place -> String in
                guard let photoRef = place.photoRef else {
                    throw NetworkError.noImage
                }
                self?.place = place
                return photoRef
            }
            .compactMap { photoRef -> AnyPublisher<UIImage, Error>? in
                let imageMaxHeight = Int(UIScreen.main.bounds.height) / 4
                return API.PlaceSearch.loadGooglePhoto(photoRef: photoRef, maxHeight: imageMaxHeight)
            }
            .flatMap { $0 } // converts into correct publisher so sink works
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.placeImage = image
                strongSelf.fadeInImage(image, forImageView: strongSelf.imageView)
            })
        
    }
}

extension CuratedCityCollectionViewCell: ImageViewFadeable {}
