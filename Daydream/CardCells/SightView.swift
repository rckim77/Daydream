//
//  SightView.swift
//  Daydream
//
//  Created by Raymond Kim on 6/1/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

protocol SightViewDelegate: class {
    func sightViewDidTap(layoutType: SightView.LayoutType)
    func sightViewDidTapBusinessStatus(status: PlaceBusinessStatus)
}

final class SightView: UIView {

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
    private lazy var businessStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.addShadow(opacity: 0.8, offset: CGSize(width: 0, height: 1))
        button.addTarget(self, action: #selector(businessStatusButtonTapped), for: .touchUpInside)
        if #available(iOS 13.4, *) {
            button.pointerStyleProvider = buttonProvider
        }
        return button
    }()

    private var layoutType: LayoutType = .middle
    private weak var delegate: SightViewDelegate?
    private var sight: Place?
    private var cancellable: AnyCancellable?

    convenience init(layoutType: LayoutType, delegate: SightViewDelegate) {
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
        addSubview(businessStatusButton)
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
        businessStatusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalTo(titleLabel.snp.leading)
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
        businessStatusButton.isHidden = true
    }

    func configureError() {
        isHidden = true
    }

    func configure(sight: Place) {
        isHidden = false
        self.sight = sight
        titleLabel.text = sight.name
        let businessStatus = sight.businessStatus
        businessStatusButton.configureWithSystemIcon(businessStatus?.imageName ?? "")
        businessStatusButton.tintColor = businessStatus?.displayColor
        businessStatusButton.isHidden = businessStatus == .operational

        updateLayers()
        cancellable = NetworkService().loadGooglePhoto(placeId: sight.placeId)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] image in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updateLayers()
                strongSelf.fadeInImage(image, forImageView: strongSelf.backgroundImageView)
                strongSelf.layoutIfNeeded()
            })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Button selector methods

    @objc
    private func handleTapGesture() {
        delegate?.sightViewDidTap(layoutType: layoutType)
    }

    @objc
    private func businessStatusButtonTapped() {
        guard let businessStatus = sight?.businessStatus else {
            return
        }
        delegate?.sightViewDidTapBusinessStatus(status: businessStatus)
    }
}

extension SightView: ImageViewFadeable {}
