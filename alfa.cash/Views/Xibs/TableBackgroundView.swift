//
//  TableBackgroundView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol TableBackgroundViewDelegate {
    func addCoin()
}

class TableBackgroundView: UIView {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomAddCoinView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var delegate: TableBackgroundViewDelegate?
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initFromNib()
    }
    
    private func initFromNib() {
        let nib =  UINib(nibName: "TableBackgroundView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        setIconTintColor()
    }
    
    func setIconTintColor() {
        icon.tintColor = ThemeManager.currentTheme == .day ? .black : .white
    }
    
    func hideIcon() {
        icon.isHidden = true
    }
    
    func setTableVewShortHeight(_ height: CGFloat) {
        topConstraint.constant = height - 75
        layoutIfNeeded()
    }

    func startSearch() {
        activityIndicator.startAnimating()
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
    }
    
    func stopSearch() {
        activityIndicator.stopAnimating()
    }
    
    func showNothingFound(_ show: Bool) {
        titleLabel.isHidden = !show
        subtitleLabel.isHidden = true
    }
    
    @IBAction func addCoin(_ sender: Any) {
        delegate?.addCoin()
    }
    
    func setupWithTitle(_ title: String, subtitle: String? = nil) {
        titleLabel.text = title
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = UIColor.kTextColor.withAlphaComponent(0.40)
        } else {
            subtitleLabel.isHidden = true
        }
        bottomAddCoinView.isHidden = true
    }
}
