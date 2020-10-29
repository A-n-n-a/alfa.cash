//
//  InviteFriendView.swift
//  alfa.cash
//
//  Created by Anna on 6/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol InviteFriendViewDelegate {
    func shareLink(_ link: String)
}

class InviteFriendView: UIView {

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeCopyIcon: UIImageView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var linkCopyIcon: UIImageView!
    
    var delegate: InviteFriendViewDelegate?
    var code = "" {
        didSet {
            codeLabel.text = code
        }
    }
    var link = "" {
        didSet {
            linkLabel.text = link
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let nib =  UINib(nibName: "InviteFriendView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
    }

    @IBAction func copyCode(_ sender: Any) {
        codeCopyIcon.image = #imageLiteral(resourceName: "copy")
        UIPasteboard.general.string = code
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.codeCopyIcon.image = #imageLiteral(resourceName: "copy_pale")
        }
    }
    
    @IBAction func copyLink(_ sender: Any) {
        linkCopyIcon.image = #imageLiteral(resourceName: "copy")
        UIPasteboard.general.string = link
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.linkCopyIcon.image = #imageLiteral(resourceName: "copy_pale")
        }
    }
    
    @IBAction func inviteFriend(_ sender: Any) {
        delegate?.shareLink(link)
    }
}
