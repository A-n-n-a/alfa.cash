//
//  View.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit
import RxLocalizer
import RxSwift
import RxCocoa

extension UIView {
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func subscribeToLocalizedString(_ string: String) {
        
        if let label = self as? UILabel {
            Localizer.shared.localized(string)
            .drive(label.rx.text)
                .disposed(by: ApplicationManager.disposeBag)
        }
        if let button = self as? UIButton {
            Localizer.shared.localized(string)
                .drive(button.rx.title(for: .normal))
            .disposed(by: ApplicationManager.disposeBag)
        }
        if let textField = self as? UITextField {
            Localizer.shared.localized(string)
                .drive(textField.rx.text)
            .disposed(by:  ApplicationManager.disposeBag)
        }
    }
    
    func drawShadow() {
        self.layer.shadowColor = #colorLiteral(red: 0.7607843137, green: 0.7607843137, blue: 0.7607843137, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 3.0, height: 6.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 7
    }
    
    func applyModalAnimation(dissmiss: Bool = false) {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = dissmiss ? .fromBottom : .fromTop 
        self.layer.add(transition, forKey: kCATransition)
    }
}
