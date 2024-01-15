//
//  SightsCarouselDataSource.swift
//  Daydream
//
//  Created by Ray Kim on 1/15/24.
//  Copyright © 2024 Raymond Kim. All rights reserved.
//

import UIKit

final class SightsCarouselDataSource: NSObject, UICollectionViewDataSource {
    
    var sights: [Place]?
    var loadingState: LoadingState = .uninitiated
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = SightsCarouselCardCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? SightsCarouselCardCell else {
            return UICollectionViewCell()
        }
        
        switch loadingState {
        case .results:
            guard let sights = sights else {
                return cell
            }
            
            cell.configure(place: sights[indexPath.row])
        default:
            return cell
        }
        
        return cell
    }
}
