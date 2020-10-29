//
//  ACTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ACTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup() {
        subscribeToTheme() 
    }
    
    func subscribeToTheme() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundColor })
    }
}
