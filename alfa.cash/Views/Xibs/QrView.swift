//
//  QrView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 05.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

protocol QrViewDelegate {
    func closeView()
}

class QrView: UIView {
    
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: BorderedButton!
    @IBOutlet weak var copiedButton: BorderedButton!
    @IBOutlet weak var qrContainer: ACContainerView!
    @IBOutlet weak var copyButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var currencyLabel: TitleNoFontLabel!
    @IBOutlet weak var currencySignLabel: SubtitleNoFontLabel!
    
    var delegate: QrViewDelegate?
    var topupResponse: TopupResponse? {
        didSet {
            setupCoinLabels()
            generateQR()
            addressLabel.text = topupResponse?.deposit.address
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
    
    func setup() {
        let nib =  UINib(nibName: "QrView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
    }
    
    func setupCoinLabels() {
        if let currency = topupResponse?.coinCurrency,
            let coin = try? TrustWalletCore.CoinType.getCoin(from: currency) {
            currencyLabel.text = coin.name.uppercased()
            currencySignLabel.text = "(\(currency.uppercased()))"
        }
    }
    
    
    func generateQR() {
        if let address = topupResponse?.deposit.address {
            let image = QRCodeGenerator().generate(from: address)
            qrImage.image = image
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        delegate?.closeView()
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        guard let address = topupResponse?.deposit.address else { return }
        UIPasteboard.general.string = address
        copyButton.isHidden = true
        copiedButton.isHidden = false
    }
}

