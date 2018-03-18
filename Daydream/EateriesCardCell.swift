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
    func didSelectEatery(_ eatery: JSON)
}

class EateriesCardCell: UITableViewCell {

    @IBOutlet weak var eatery1Btn: UIButton!
    @IBOutlet weak var eatery2Btn: UIButton!
    @IBOutlet weak var eatery3Btn: UIButton!

    weak var delegate: EateriesCardCellDelegate?
    var eateries: [JSON]? {
        didSet {
            guard let eateries = eateries, eateries.count >= 3 else {
                isHidden = true
                return
            }

            isHidden = false

            let eatery1 = eateries[0]
            let eatery2 = eateries[1]
            let eatery3 = eateries[2]

            eatery1Btn.setTitle(eatery1.dictionaryValue["name"]?.stringValue, for: .normal)
            eatery2Btn.setTitle(eatery2.dictionaryValue["name"]?.stringValue, for: .normal)
            eatery3Btn.setTitle(eatery3.dictionaryValue["name"]?.stringValue, for: .normal)

            loadBackgroundImage(for: 1, with: eatery1)
            loadBackgroundImage(for: 2, with: eatery2)
            loadBackgroundImage(for: 3, with: eatery3)
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

    private func loadBackgroundImage(for button: Int, with pointOfInterest: JSON) {
        if let imageUrl = URL(string: pointOfInterest["image_url"].stringValue) {
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
