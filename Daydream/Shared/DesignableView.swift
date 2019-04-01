//
//  DesignableView.swift
//  Daydream
//
//  Created by Raymond Kim on 3/31/19.
//  Copyright © 2019 Raymond Kim. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let shadowColor = layer.shadowColor {
                layer.shadowColor = shadowColor
            }
            return nil
        }
        set {
            if let shadowColor = newValue {
                layer.shadowColor = shadowColor.cgColor
            }
        }
    }
}
