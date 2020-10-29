//
//  ConnectView.swift
//  alfa.cash
//
//  Created by Anna on 6/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol PayoutRequestViewDelegate {
    func dismissView()
}

class PayoutRequestView: UIView {
    
    var delegate: PayoutRequestViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let nib =  UINib(nibName: "PayoutRequestView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
    }

    @IBAction func connectAction(_ sender: Any) {
        delegate?.dismissView()
    }
    
}
