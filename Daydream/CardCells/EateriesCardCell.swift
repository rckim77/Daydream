//
//  EateriesCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 3/3/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces
import SnapKit

protocol EateriesCardCellDelegate: AnyObject {
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectEatery eatery: Eatery)
    func eateriesCardCell(_ cell: EateriesCardCell, didSelectFallbackEatery eatery: Placeable)
}

class EateriesCardCell: UITableViewCell {

    @IBOutlet weak var eatery1View: UIView!
    private let eatery1GradientView = GradientView()
    @IBOutlet weak var eatery1ImageView: UIImageView!
    private let eatery1Label = CardLabel()
    @IBOutlet weak var eatery2View: UIView!
    private let eatery2GradientView = GradientView()
    @IBOutlet weak var eatery2ImageView: UIImageView!
    private let eatery2Label = CardLabel()
    @IBOutlet weak var eatery3View: UIView!
    private let eatery3GradientView = GradientView()
    @IBOutlet weak var eatery3ImageView: UIImageView!
    private let eatery3Label = CardLabel()

    weak var delegate: EateriesCardCellDelegate?
    private var eateries: [Eatery]?
    private var fallbackEateries: [Placeable]?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        eatery1View.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        eatery2View.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(withSender:)))
        eatery3View.addGestureRecognizer(tapGesture3)

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        eatery1ImageView.image = nil
        eatery2ImageView.image = nil
        eatery3ImageView.image = nil

        // add programmatic labels to views
        eatery1View.addSubview(eatery1GradientView)
        eatery1View.addSubview(eatery1Label)
        eatery2View.addSubview(eatery2GradientView)
        eatery2View.addSubview(eatery2Label)
        eatery3View.addSubview(eatery3GradientView)
        eatery3View.addSubview(eatery3Label)

        eatery1Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        eatery1GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }

        eatery2Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        eatery2GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }

        eatery3Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        eatery3GradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    // Note: On iOS 13, setNeedsLayout() is called first before UIViews are
    // added as subviews so we can't update UIViews just yet.
    private func updateCellLayout() {
        eatery1View.addTopRoundedCorners()
        eatery2View.layer.masksToBounds = true
        eatery3View.addBottomRoundedCorners()

        eatery1GradientView.gradientLayer.frame = eatery1GradientView.bounds
        eatery2GradientView.gradientLayer.frame = eatery2GradientView.bounds
        eatery3GradientView.gradientLayer.frame = eatery3GradientView.bounds

        layoutIfNeeded()
    }

    @objc
    private func handleTapGesture(withSender sender: UITapGestureRecognizer) {
        if let eateries = eateries {
             var eatery = eateries[0]

             if sender.view  == eatery1View {
                 eatery = eateries[0]
             } else if sender.view == eatery2View {
                 eatery = eateries[1]
             } else if sender.view == eatery3View {
                 eatery = eateries[2]
             }

            delegate?.eateriesCardCell(self, didSelectEatery: eatery)
        } else if let fallbackEateries = fallbackEateries {
             var eatery = fallbackEateries[0]

             if sender.view  == eatery1View {
                 eatery = fallbackEateries[0]
             } else if sender.view == eatery2View {
                 eatery = fallbackEateries[1]
             } else if sender.view == eatery3View {
                 eatery = fallbackEateries[2]
             }

            delegate?.eateriesCardCell(self, didSelectFallbackEatery: eatery)
        }
    }

    private func loadBackgroundImage(forButton button: Int, with eatery: Eatery) {
        if let imageUrl = URL(string: eatery.imageUrl) {
           URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                guard let strongSelf = self, let data = data else {
                    return
                }

                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else {
                        return
                    }

                    var imageView = UIImageView()
                    switch button {
                    case 1:
                        imageView = strongSelf.eatery1ImageView
                    case 2:
                        imageView = strongSelf.eatery2ImageView
                    case 3:
                        imageView = strongSelf.eatery3ImageView
                    default:
                        break
                    }

                    strongSelf.updateCellLayout()
                    strongSelf.fadeInImage(image, forImageView: imageView)
                }
            }.resume()
        }
    }

    private func loadBackgroundImage(forButton button: Int, withFallbackEatery eatery: Placeable) {
        guard let placeId = eatery.placeableId else {
            return
        }
        NetworkService().loadPhoto(with: placeId, success: { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            var imageView = UIImageView()

            switch button {
            case 1:
                imageView = strongSelf.eatery1ImageView
            case 2:
                imageView = strongSelf.eatery2ImageView
            case 3:
                imageView = strongSelf.eatery3ImageView
            default:
                break
            }

            strongSelf.updateCellLayout()
            strongSelf.fadeInImage(image, forImageView: imageView)
        }, failure: { _ in })
    }

    func configure(_ eateries: [Eatery]) {
        self.eateries = eateries
        self.fallbackEateries = nil
        isHidden = false

        [eatery1Label, eatery2Label, eatery3Label].enumerated().forEach { (index, label) in
            label.text = createDisplayText(eateries[index].name, priceRating: eateries[index].price)
        }

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        [eatery1ImageView, eatery2ImageView, eatery3ImageView].forEach { imageView in
            imageView?.image = nil
        }

        eateries.enumerated().forEach { (index, eatery) in
            loadBackgroundImage(forButton: index + 1, with: eatery)
        }
    }

    func configureWithFallbackEateries(_ eateries: [Placeable]) {
        self.eateries = nil
        self.fallbackEateries = eateries
        isHidden = false

        [eatery1Label, eatery2Label, eatery3Label].enumerated().forEach { (index, label) in
            if let name = eateries[index].placeableName {
                label.text = createDisplayText(name)
            }
        }

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        [eatery1ImageView, eatery2ImageView, eatery3ImageView].forEach { imageView in
            imageView?.image = nil
        }

        eateries.enumerated().forEach { (index, eatery) in
            loadBackgroundImage(forButton: index + 1, withFallbackEatery: eatery)
        }
    }

    func configureForNoResults() {
        isHidden = true
    }

    private func createDisplayText(_ name: String, priceRating: String? = nil) -> String {
        if let priceRating = priceRating {
            return "\(name) • \(priceRating)"
        } else {
            return name
        }
    }
}

extension EateriesCardCell: ImageViewFadeable {}
