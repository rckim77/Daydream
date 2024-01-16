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
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad

        switch loadingState {
        case .loading, .error, .uninitiated:
            return isIpad ? 7 : 3
        case .results:
            return eateries?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = EateriesCarouselCardCell.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? EateriesCarouselCardCell else {
            return UICollectionViewCell()
        }
        
        switch loadingState {
        case .loading:
            cell.configureLoading()
        case .results:
            guard let eateries = eateries else {
                return cell
            }
            
            let eatery = eateries[indexPath.row]
            cell.configure(eatery: eatery)
        case .error:
            cell.configureError()
        default:
            return cell
        }
        
        return cell
    }
}
