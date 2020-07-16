//
//  UIDevice+Helpers.swift
//  Daydream
//
//  Created by Raymond Kim on 3/30/19.
//  Copyright © 2019 Raymond Kim. All rights reserved.
//

import UIKit

extension UIDevice {
    enum DeviceSize {
        case iPhoneSE, iPhone8, iPhone8Plus, iPhone11Pro, iPhone11, iPhone11ProMax, unknown
    }

    func getVersionCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        // swiftlint:disable line_length
        let versionCode: String = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!

        return versionCode
    }

    var deviceSize: DeviceSize {
        let deviceHeight = UIScreen.main.bounds.height

        switch deviceHeight {
        case 568:
            return .iPhoneSE // 4"
        case 667:
            return .iPhone8 // 4.7"
        case 736:
            return .iPhone8Plus // 5.5"
        case 812:
            return .iPhone11Pro // 5.8"
        case 896:
            let versionCode = getVersionCode()
            if versionCode == "iPhone11,8" || versionCode == "iPhone12,1" { // XR or 11
                return .iPhone11 // 6.1"
            } 
            return .iPhone11ProMax // 6.5"
        default:
            return .unknown
        }
    }

    var notchHeight: CGFloat {
        if deviceSize == .iPhoneSE || deviceSize == .iPhone8 || deviceSize == .iPhone8Plus { // no notch devices
            return 24
        } else { // notch devices
            return 44
        }
    }
}
