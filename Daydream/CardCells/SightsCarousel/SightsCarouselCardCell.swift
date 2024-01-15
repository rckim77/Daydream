//
//  SightsCarouselCardCell.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

final class SightsCarouselCardCell: UICollectionViewCell {
    
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
    
    static let reuseIdentifier = "sightsCarouselCardCell"

    private var titleLabelPadding: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
    }

    var place: Place?
    var placeImage: UIImage?
    private var cancellable: AnyCancellable?
    
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
    
    func configure(place: Place) {
        titleLabel.text = place.name
        
        if let cachedImage = ImageCache.shared.get(forKey: place.name) {
            gradientView.updateFrame()
            placeImage = cachedImage
        } else {
            cancellable = API.PlaceSearch.loadPlace(name: place.name, queryType: .placeByName)?
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
                    strongSelf.gradientView.updateFrame()
                    strongSelf.placeImage = image
                    strongSelf.fadeInImage(image, forImageView: strongSelf.imageView)
                    
                    ImageCache.shared.set(image, forKey: place.name)
                })
        }
    }
    
    func configureLoading() {
        imageView.image = nil
        titleLabel.text = nil
        placeImage = nil
        place = nil
    }
    
    func configureError() {
        imageView.image = nil
        titleLabel.text = nil
        placeImage = nil
        place = nil
    }
}

extension SightsCarouselCardCell: ImageViewFadeable {}
