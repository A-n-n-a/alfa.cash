//
//  SpeedTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 05.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol SpeedTableViewCellDelegate {
    
}

class SpeedTableViewCell: UITableViewCell {

    @IBOutlet weak var blueContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var checkmarkContainer: UIImageView!
    
    var delegate: SpeedTableViewCellDelegate?
    
    var address: String! {
        didSet {
            
            titleLabel.isHidden = true
            checkmarkContainer.isHidden = true
            
            if let firstChar = address.first, firstChar == "." {
                address = String(address.dropFirst())
            }
            address = address.components(separatedBy: ".").first
            
            subtitleLabel.text = address
            setupBackground()
        }
    }
    
    func setSpeed(_ speed: Speed, fee: String) {
        titleLabel.text = speed.localizedKey.localized()
        checkmarkContainer.isHidden = speed != WalletManager.selectedSpeed
        subtitleLabel.text = "\("NETWORK_FEE".localized()) \(fee)"
        setupBackground()
    }
    
    func setupBackground() {
        let bgColorView = UIView(frame: frame)
        bgColorView.backgroundColor = .white
        selectedBackgroundView = bgColorView
    }
    
    func selection() {
        blueContainer.backgroundColor =  #colorLiteral(red: 0.8666666667, green: 0.8745098039, blue: 0.8666666667, alpha: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.blueContainer.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9764705882, blue: 1, alpha: 1)
        }
    }
}
