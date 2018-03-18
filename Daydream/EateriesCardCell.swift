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

    @IBOutlet weak var eatery1Btn: UIButton!
    @IBOutlet weak var eatery2Btn: UIButton!
    @IBOutlet weak var eatery3Btn: UIButton!

    weak var delegate: EateriesCardCellDelegate?
    var eateries: [Eatery]? {
        didSet {
            // POSTLAUNCH: - Update url comparison
            if let eateries = eateries,
                eateries.count >= 3,
                oldValue?.count != 0,
                eateries[0].url != oldValue?[0].url { // don't set when user is simply scrolling

                eatery1Btn.setTitle(eateries[0].name, for: .normal)
                eatery2Btn.setTitle(eateries[1].name, for: .normal)
                eatery3Btn.setTitle(eateries[2].name, for: .normal)

                loadBackgroundImage(for: 1, with: eateries[0])
                loadBackgroundImage(for: 2, with: eateries[1])
                loadBackgroundImage(for: 3, with: eateries[2])
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        eatery1Btn.addTopRoundedCorners()
        eatery3Btn.addBottomRoundedCorners()

        // reset image (to prevent background images being reused due to dequeueing reusable cells)
        eatery1Btn.setBackgroundImage(nil, for: .normal)
        eatery2Btn.setBackgroundImage(nil, for: .normal)
        eatery3Btn.setBackgroundImage(nil, for: .normal)
    }

    @IBAction func eatery1BtnTapped(_ sender: Any) {
        guard let eateries = eateries else { return }
        delegate?.didSelectEatery(eateries[0])
    }

    @IBAction func eatery2BtnTapped(_ sender: Any) {
        guard let eateries = eateries else { return }
        delegate?.didSelectEatery(eateries[1])
    }

    @IBAction func eatery3BtnTapped(_ sender: Any) {
        guard let eateries = eateries else { return }
        delegate?.didSelectEatery(eateries[2])
    }

    private func loadBackgroundImage(for button: Int, with eatery: Eatery) {
        if let imageUrl = URL(string: eatery.imageUrl) {
           URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, _ in
                guard let strongSelf = self, let data = data else { return }

                DispatchQueue.main.async {
                    if button == 1 {
                        strongSelf.eatery1Btn.setBackgroundImage(UIImage(data: data), for: .normal)
                    } else if button == 2 {
                        strongSelf.eatery2Btn.setBackgroundImage(UIImage(data: data), for: .normal)
                    } else if button == 3 {
                        strongSelf.eatery3Btn.setBackgroundImage(UIImage(data: data), for: .normal)
                    }

                }
            }.resume()
        }
    }
}
