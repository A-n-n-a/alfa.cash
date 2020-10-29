//
//  ConnectView.swift
//  alfa.cash
//
//  Created by Anna on 6/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol ConnectViewDelegate {
    func connectToAlfa()
}

class ConnectView: UIView {
    
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var signupView: UIView!
    
    var delegate: ConnectViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let nib =  UINib(nibName: "ConnectView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        signupView.layer.borderWidth = 1
        signupView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.32).cgColor
        signinView.layer.borderWidth = ThemeManager.currentTheme == .day ? 0 : 1
        signinView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.32).cgColor
    }

    @IBAction func connectAction(_ sender: Any) {
        delegate?.connectToAlfa()
    }
    
}
