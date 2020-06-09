//
//  MapReviewCard.swift
//  Daydream
//
//  Created by Raymond Kim on 5/23/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit
import Combine

final class MapReviewCard: UIView {

    static let height: CGFloat = 160

    // Cannot have rounded corners and drop shadow in same view layer
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addRoundedCorners(radius: 10)
        return view
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Author"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private lazy var authorImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private lazy var starsView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()

    private lazy var star1ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var star2ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var star3ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var star4ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var star5ImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private var profileImageCancellable: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addShadow(opacity: 0.6, offset: CGSize(width: 0, height: 1), radius: 2)
        addSubview(containerView)

        containerView.addSubview(authorLabel)
        containerView.addSubview(authorImageView)
        containerView.addSubview(reviewLabel)
        containerView.addSubview(starsView)
        starsView.addArrangedSubview(star1ImageView)
        starsView.addArrangedSubview(star2ImageView)
        starsView.addArrangedSubview(star3ImageView)
        starsView.addArrangedSubview(star4ImageView)
        starsView.addArrangedSubview(star5ImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        authorImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
            make.size.equalTo(36)
        }

        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(authorImageView.snp.trailing).offset(8)
            make.centerY.equalTo(authorImageView.snp.centerY)
        }

        reviewLabel.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview().inset(16)
            make.top.equalTo(authorImageView.snp.bottom).offset(6)
        }

        starsView.snp.makeConstraints { make in
            make.leading.equalTo(authorLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(authorImageView.snp.centerY)
        }

        [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView].forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.size.equalTo(20)
            }
        }
    }

    func configure(_ review: Review) {
        authorLabel.text = review.authorName
        reviewLabel.text = review.text
        updateStars(rating: review.rating)
        authorImageView.image = nil

        guard let profileUrl = review.profilePhotoUrl, let url = URL(string: profileUrl) else {
            return
        }

        profileImageCancellable = NetworkService.loadImage(url: url)
            .assign(to: \.image, on: authorImageView)
    }

    private func updateStars(rating: Int) {
        guard rating >= 0 && rating <= 5 else {
            return
        }

        let starImageViews = [star1ImageView, star2ImageView, star3ImageView, star4ImageView, star5ImageView]
        for i in 1..<6 {
            if i <= rating {
                starImageViews[i-1].image = UIImage(systemName: "star.fill")
                starImageViews[i-1].tintColor = .systemYellow
            } else {
                starImageViews[i-1].image = UIImage(systemName: "star")
                starImageViews[i-1].tintColor = .lightGray
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
