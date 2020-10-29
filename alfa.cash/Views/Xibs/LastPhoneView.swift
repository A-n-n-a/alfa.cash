//
//  LastPhoneView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 07.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol LastPhoneDelegate {
    func useLastPhone()
    func cancelAction()
}

class LastPhoneView: UIView {
    
    @IBOutlet weak var phoneLabel: TitleNoFontLabel!
    
    var delegate: LastPhoneDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    convenience init(phone: String) {
        self.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 252))
        
        phoneLabel.text = phone
    }
    
    private func setup() {
        let nib =  UINib(nibName: "LastPhoneView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .down
        self.addGestureRecognizer(swipe)
        
    }
    
    @objc func swipeAction() {
        delegate?.cancelAction()
    }
    
    @IBAction func usePhoneAction(_ sender: Any) {
        delegate?.useLastPhone()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        delegate?.cancelAction()
    }
}
