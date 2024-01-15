//
//  FloatingView.swift
//  Daydream
//
//  Created by Ray Kim on 7/11/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

class FloatingView: UIView {

    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addRoundedCorners(radius: self.cornerRadius)
        return view
    }()
    
    private lazy var shadowView: ShadowView = {
        let shadowView = ShadowView(cornerRadius: self.cornerRadius)
        return shadowView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        return label
    }()
    
    private let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        
        addSubview(shadowView)
        addSubview(titleView)
        titleView.addSubview(titleLabel)
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
