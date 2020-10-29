//
//  BiometryTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class BiometryTableViewCell: IndicatorTableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var subtitleLabel: SubtitleLabel!
    
    var securityType: SecurityType! {
        didSet {
            switch securityType {
            case .faceId:
                icon.image = #imageLiteral(resourceName: "faceId")
                titleLabel.setText("USE_FACE_ID")
                subtitleLabel.isHidden = false
            case .touchId:
                icon.image = #imageLiteral(resourceName: "touchIdIcn")
                titleLabel.setText("USE_TOUCH_ID")
                subtitleLabel.isHidden = false
            case .passcode:
                icon.image = #imageLiteral(resourceName: "keypad")
                titleLabel.setText("SETUP_PASSCODE")
                subtitleLabel.isHidden = true
            default:
                break
            }
        }
    }
}
