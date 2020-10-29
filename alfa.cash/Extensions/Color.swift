//
//  Color.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    static var kBlueMedium: UIColor {
        return UIColor(red: 8.0 / 255.0, green: 48.0 / 255.0, blue: 127.0 / 255.0, alpha: 1.0)
    }
    
    static var kDefaultBackgroundNight: UIColor {
        return "#081B5F".hexColor()
    }
    
    static var kDefaultBackgroundTrueNight: UIColor {
        return "#0F1012".hexColor()
    }
    
    
    static var kCellBackgroundDay: UIColor {
        return "#F3F9FF".hexColor()
    }
    
    static var kCellBackgroundNight: UIColor {
        return "#001052".hexColor()
    }
    
    static var kCellBackgroundTrueNight: UIColor {
        return "#131415".hexColor()
    }
    
    static var kWhiteColor: UIColor {
        return UIColor.white
    }
    
    static var kWhiteOpaqueColor: UIColor {
        return UIColor.white.withAlphaComponent(0.3)
    }
    
    static var kBlackColor: UIColor {
        return UIColor.black
    }
    
    static var kNavBarTextColor: UIColor {
        return "#2F2E2E".hexColor()
    }
    
    static var kHeaderColor: UIColor {
        return "#2F2E2E".hexColor().withAlphaComponent(0.5)
    }
    
    static var kTextColor: UIColor {
        return "#232323".hexColor()
    }
    
    static var kButtonColor: UIColor {
        return "#0A85FF".hexColor()
    }
    
    static var kNoBorderButtonTextColor: UIColor {
        return UIColor.white.withAlphaComponent(0.4)
    }
    
    static var kNoBorderBackgroundColor: UIColor {
        return UIColor.clear
    }
    
    static var kTextFieldBackgroundTrueNight: UIColor {
        return "#232527".hexColor()
    }
    
    static var kTextFieldBorderDay: UIColor {
        return "#E3ECF6".hexColor()
    }
    
    static var kPlaceholderColor: UIColor {
        return "#AAC3DC".hexColor()
    }
    
    static var kErrorColor: UIColor {
        return "#DA5252".hexColor()
    }
    
    static var kAvailableColor: UIColor {
        return "#E5E5E5".hexColor()
    }
    
    static var kPinButtonColor: UIColor {
        return "#CCE4C6".hexColor()
    }
    
    static var kPinRowColor: UIColor {
        return "#E2FADD".hexColor()
    }
    
    static var kTextFieldBorderColor: UIColor {
        return "#85C2FF".hexColor()
    }
    
    static var kTurquoiseColor: UIColor {
        return "#36C5D3".hexColor()
    }
    
    static var kTagColor: UIColor {
        return "#A2F291".hexColor().withAlphaComponent(0.3)
    }
    
    static var kTagTextColor: UIColor {
        return "#527F49".hexColor()
    }
    
    static var kQRBackgroundTrueNight: UIColor {
        return UIColor(red: 35/255, green: 37/255, blue: 39/255, alpha: 1)
    }
    
    static var kQRBackgroundNight: UIColor {
        return UIColor(red: 0/255, green: 16/255, blue: 82/255, alpha: 1)
    }
    
    static var kMenuBackgroundTrueNight: UIColor {
        return UIColor(red: 10/255, green: 11/255, blue: 12/255, alpha: 1)
    }
}
