//
//  EateryView.swift
//  Daydream
//
//  Created by Raymond Kim on 6/2/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

protocol EateryViewDelegate: class {
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
        gradientView.gradientLayer.frame = gradientView.bounds
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

        switch eatery.type {
        case .yelp:
            guard let urlString = eatery.eatableImageUrl,
                let imageUrl = URL(string: urlString) else {
                return
            }

            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                guard let strongSelf = self, let data = data else {
                    return
                }

                DispatchQueue.main.async {
                   guard let image = UIImage(data: data) else {
                       return
                   }

                   strongSelf.updateLayers()
                   strongSelf.fadeInImage(image, forImageView: strongSelf.backgroundImageView)
                   strongSelf.layoutIfNeeded()
                }
            }.resume()
        case .google:
            guard let id = eatery.id else {
                return
            }
            NetworkService().loadPhoto(placeId: id, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }

                if case .success(let image) = result {
                    strongSelf.updateLayers()
                    strongSelf.fadeInImage(image, forImageView: strongSelf.backgroundImageView)
                }
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
