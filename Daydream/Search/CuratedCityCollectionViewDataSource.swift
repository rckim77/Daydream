//
//  CuratedCityCollectionViewDataSource.swift
//  Daydream
//
//  Created by Ray Kim on 7/15/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

final class CuratedCityCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    private var cityNames: [String] = []

    init(cityCount: Int) {
        super.init()
        cityNames = Array(repeating: "", count: cityCount).map { emptyString in
            getRandomCity() ?? emptyString
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cityNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CuratedCityCollectionViewCell.reuseIdentifier, for: indexPath) as? CuratedCityCollectionViewCell
        cell?.configure(name: cityNames[indexPath.row])
        return cell ?? UICollectionViewCell()
    }
}

extension CuratedCityCollectionViewDataSource: RandomCitySelectable {}
