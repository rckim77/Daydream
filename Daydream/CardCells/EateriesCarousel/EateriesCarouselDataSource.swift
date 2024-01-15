//
//  EateriesCarouselDataSource.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit

final class EateriesCarouselDataSource: NSObject, UICollectionViewDataSource {
    
    var eateries: [Eatable]?
    var loadingState: LoadingState = .uninitiated
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let eateries = eateries else {
            return 3
        }
        
        return eateries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = EateriesCarouselCardCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? EateriesCarouselCardCell else {
            return UICollectionViewCell()
        }
        
        switch loadingState {
        case .results:
            guard let eateries = eateries else {
                return cell
            }
            
            let eatery = eateries[indexPath.row]
            cell.configure(eatery: eatery)
        default:
            return cell
        }
        
        return cell
    }
}
