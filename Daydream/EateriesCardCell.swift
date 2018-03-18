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

protocol EateriesCardCellDelegate: class {
    func didSelectEatery(_ eatery: Eatery)
}

class EateriesCardCell: UITableViewCell {

    @IBOutlet weak var eatery1View: UIView!
    @IBOutlet weak var eatery1ImageView: UIImageView!
    @IBOutlet weak var eatery1Label: UILabel!
    @IBOutlet weak var eatery2View: UIView!
    @IBOutlet weak var eatery2ImageView: UIImageView!
    @IBOutlet weak var eatery2Label: UILabel!
    @IBOutlet weak var eatery3View: UIView!
    @IBOutlet weak var eatery3ImageView: UIImageView!
    @IBOutlet weak var eatery3Label: UILabel!
    @IBOutlet weak var noContentLabel: UILabel!

    weak var delegate: EateriesCardCellDelegate?
    var eateries: [Eatery]? {
        didSet {
            if let eateries = eateries, eateries.count >= 3, oldValue?.count != 0 {
                // display content only if we've made another API call, otherwise do nothing
                // POSTLAUNCH: - Update url comparison
                if eateries[0].url != oldValue?[0].url {
                    toggleViews([eatery1View, eatery2View, eatery3View], willHide: false)

                    eatery1Label.text = eateries[0].name
                    eatery2Label.text = eateries[1].name
                    eatery3Label.text = eateries[2].name

                    // reset image (to prevent background images being reused due to dequeueing reusable cells)
                    eatery1ImageView.image = nil
                    eatery2ImageView.image = nil
                    eatery3ImageView.image = nil

                    loadBackgroundImage(for: 1, with: eateries[0])
                    loadBackgroundImage(for: 2, with: eateries[1])
                    loadBackgroundImage(for: 3, with: eateries[2])
                }
            } else { // before response from API or error
                toggleViews([eatery1View, eatery2View, eatery3View], willHide: true)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        eatery1View.addTopRoundedCorners()
        eatery2View.layer.masksToBounds = true
        eatery3View.addBottomRoundedCorners()

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
    }

    @objc
    private func handleTapGesture(withSender sender: UITapGestureRecognizer) {
        guard let eateries = eateries else { return }

        var eatery = eateries[0]

        if sender.view  == eatery1View {
            eatery = eateries[0]
        } else if sender.view == eatery2View {
            eatery = eateries[1]
        } else if sender.view == eatery3View {
            eatery = eateries[2]
        }

       delegate?.didSelectEatery(eatery)
    }

    private func loadBackgroundImage(for button: Int, with eatery: Eatery) {
        if let imageUrl = URL(string: eatery.imageUrl) {
           URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                guard let strongSelf = self, let data = data else { return }

                DispatchQueue.main.async {
                    if button == 1 {
                        strongSelf.eatery1ImageView.image = UIImage(data: data)
                    } else if button == 2 {
                        strongSelf.eatery2ImageView.image = UIImage(data: data)
                    } else if button == 3 {
                        strongSelf.eatery3ImageView.image = UIImage(data: data)
                    }

                }
            }.resume()
        }
    }
    
    private func toggleViews(_ views: [UIView], willHide: Bool) {
        noContentLabel.isHidden = !willHide

        for view in views {
            view.isHidden = willHide
        }
    }
}
