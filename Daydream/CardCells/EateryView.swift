//
//  EateryView.swift
//  Daydream
//
//  Created by Raymond Kim on 6/2/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

protocol EateryViewDelegate: AnyObject {
    func eateryViewDidTapEatery(layoutType: EateryView.LayoutType)
}

final class EateryView: UIView {

    enum LayoutType: Int {
        case top = 0
        case middle
        case bottom
    }

    private let loadingView = CellLoadingView()
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let gradientView = GradientView()
    private let titleLabel = CardLabel()

    private var layoutType: LayoutType = .middle
    private weak var delegate: EateryViewDelegate?
    private var eatery: Eatable?
    private var cancellable: AnyCancellable?
    private var maxHeight: Int {
        Int(UIScreen.main.bounds.height)
    }

    convenience init(layoutType: LayoutType, delegate: EateryViewDelegate) {
        self.init(frame: .zero)
        self.layoutType = layoutType
        self.delegate = delegate

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }

    private func updateLayers() {
        switch layoutType {
        case .top:
            addTopRoundedCorners()
        case .middle:
            layer.masksToBounds = true
        case .bottom:
            addBottomRoundedCorners()
        }
        gradientView.updateFrame()
    }

    private func addViews() {
        addSubview(loadingView)
        addSubview(backgroundImageView)
        addSubview(gradientView)
        addSubview(titleLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    func resetBackgroundImage() {
        backgroundImageView.image = nil
    }

    func configureLoading() {
        isHidden = false
        updateLayers()
        backgroundImageView.image = nil
        titleLabel.text = ""
    }

    func configureError() {
        isHidden = true
    }

    func configure(eatery: Eatable) {
        isHidden = false
        self.eatery = eatery
        titleLabel.text = createDisplayText(eatery.name, priceRating: eatery.priceIndicator)
        updateLayers()
        
        switch eatery.type {
        case .yelp:
            guard let urlString = eatery.eatableImageUrl,
                let imageUrl = URL(string: urlString) else {
                return
            }

            cancellable = API.Image.loadImage(url: imageUrl)
                .sink(receiveValue: { [weak self] image in
                    guard let strongSelf = self, let image = image else {
                        return
                    }
                    strongSelf.updateLayers()
                    strongSelf.fadeInImage(image, forImageView: strongSelf.backgroundImageView)
                })

        case .google:
            cancellable = API.PlaceSearch.loadGooglePhoto(photoRef: eatery.photoRef, maxHeight: maxHeight)?
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.updateLayers()
                    strongSelf.fadeInImage(image, forImageView: strongSelf.backgroundImageView)
                })
        }
    }

    private func createDisplayText(_ name: String, priceRating: String? = nil) -> String {
        if let priceRating = priceRating {
            return "\(name) • \(priceRating)"
        } else {
            return name
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Button selector methods

    @objc
    private func handleTapGesture() {
        delegate?.eateryViewDidTapEatery(layoutType: layoutType)
    }
}

extension EateryView: ImageViewFadeable {}
