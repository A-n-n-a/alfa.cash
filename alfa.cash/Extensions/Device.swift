//
//  Device.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 31.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

extension UIDevice {
    func iPhoneSE() -> Bool {
        let fourInchScreenHeight: CGFloat = 568
        let dimensionToCheck = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)
        let is4InchPhone = dimensionToCheck == fourInchScreenHeight && userInterfaceIdiom == .phone
        
        return is4InchPhone
    }
    
    func iPhone6() -> Bool {
        let fourInchScreenHeight: CGFloat = 667
        let dimensionToCheck = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)
        let is6Phone = dimensionToCheck == fourInchScreenHeight && userInterfaceIdiom == .phone
        
        return is6Phone
    }
    
    func iPhonePlus() -> Bool {
        let fourInchScreenHeight: CGFloat = 736
        let dimensionToCheck = max(UIScreen.main.bounds.size.height, UIScreen.main.bounds.size.width)
        let isPlusPhone = dimensionToCheck == fourInchScreenHeight && userInterfaceIdiom == .phone
        
        return isPlusPhone
    }
    
    func isFrameless() -> Bool {
        var top: CGFloat
        if #available(iOS 13.0, *) {
            let sharedSceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let window = sharedSceneDelegate?.window
            top = window?.safeAreaInsets.top ?? 0
        } else {
            top = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        return top > 20
    }
}

