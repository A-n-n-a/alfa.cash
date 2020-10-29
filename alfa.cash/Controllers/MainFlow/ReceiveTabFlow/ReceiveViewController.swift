//
//  ReceiveViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import BitcoinKit

class ReceiveViewController: BaseViewController {
    
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: BorderedButton!
    @IBOutlet weak var copiedButton: BorderedButton!
    @IBOutlet weak var warningView: ACContainerView!
    @IBOutlet weak var warningTitle: TitleNoFontLabel!
    @IBOutlet weak var warningMessage: TitleNoFontLabel!
    @IBOutlet weak var qrContainer: ACContainerView!
    @IBOutlet weak var warningViewHeight: NSLayoutConstraint!
    @IBOutlet weak var aspectConstraint: NSLayoutConstraint!
    @IBOutlet weak var aspectHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var copyButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var generateStandardAddressView: UIView!
    @IBOutlet weak var generateSegwitAddressView: UIView!
    
    var wallet: Wallet?
    var address: String? {
        didSet {
            setUpUI()
        }
    }
    var derivation = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if let currency = wallet?.currency.uppercased() {
            setUpTransactionsNavBar(title: "\("RECEIVE".localized()) \(currency)", subtitle: "SHARE_YOUR_ADDRESS".localized(), rightButtonImage: #imageLiteral(resourceName: "share"), rightButtonSelector: #selector(share))
        }
        
        address = wallet?.account
        
        let size: CGSize = "COPY_ADDRESS".localized().size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        copyButtonWidth.constant = size.width + 20
        view.layoutIfNeeded()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        showQrContainer(false)
        receiveAddress()
        warningViewHeight.constant = 0
    }
    
    func showQrContainer(_ show: Bool) {
        aspectConstraint.isActive = show
        aspectHideConstraint.isActive = !show
        copyButton.isHidden = !show
        if !show {
            copiedButton.isHidden = true
        }
    }
    
    func receiveAddress() {
        guard let wallet = wallet else { return }
        NetworkManager.receive(walletId: wallet.id) { [weak self] (receive, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                    self?.address = self?.wallet?.account
                }
                if let isActionRequired = receive?.isActionRequired, let isActive = receive?.isActive {
                    switch wallet.coin {
                    case .bitcoin, .litecoin, .bitcoinCash:
                        if let derivation = receive?.derivation {
                            self?.derivation = derivation
                            self?.generateStandardAddressView.isHidden = false
                            if wallet.coin != .bitcoinCash {
                                self?.generateSegwitAddressView.isHidden = false
                            }
                        }
                    case .eos:
                        switch (isActive, isActionRequired) {
                        case (false, false):
                            if let vc = UIStoryboard.get(flow: .receiveFlow).get(controller: .eosActivationVC) as? EosActivationViewController {
                                vc.wallet = wallet
                                self?.navigationController?.pushViewController(vc, animated: true)
                                return
                            }
                            print("Activate Eos")
                        case (false, true):
                            self?.warningTitle.text = String(format:  "CRYPTO_WARNING_TITLE".localized(),wallet.currency.uppercased())
                            self?.warningMessage.text = "EOS_ACTIVATION_PENDING".localized()
                            self?.warningView.isHidden = false
                            self?.warningViewHeight.constant = 285
                            self?.showQrContainer(false)
                            return
                        default:
                            break
                        }
                    case .stellar:
                        if !isActive {
                            print("Activate Stellar")
                        }
                        if isActionRequired {
                            self?.warningTitle.text = String(format:  "CRYPTO_WARNING_TITLE".localized(),wallet.currency.uppercased())
                            self?.warningMessage.text = "XLM_ACTIVATION_DESCRIPTION".localized()
                            self?.warningView.isHidden = false
                            self?.warningViewHeight.constant = 300
                        }
                    case .xrp:
                        if isActionRequired {
                            self?.warningTitle.text = String(format:  "CRYPTO_WARNING_TITLE".localized(),wallet.currency.uppercased())
                            self?.warningMessage.text = "XRP_ACTIVATION_DESCRIPTION".localized()
                            self?.warningView.isHidden = false
                            self?.warningViewHeight.constant = 285
                        }
                    default:
                        break
                    }
                    self?.showQrContainer(true)
                }
            }
        }
    }
    
    func getAddressForDerivation(_ derivation: Int) -> String? {
        guard let mnemonic = KeychainWrapper.standart.getMnemonic() else { return nil }
        #if DEV
        let bchNetwork = BitcoinKit.Network.testnetBCH
        let btcNetwork = BitcoinKit.Network.testnetBTC
        #else
        let bchNetwork = BitcoinKit.Network.testnetBCH
        let btcNetwork = BitcoinKit.Network.testnetBTC
        #endif
        let network: BitcoinKit.Network = wallet?.coin == .bitcoinCash ? bchNetwork : btcNetwork
        if let wlt = try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: network, account: UInt32(derivation)) {
            return wlt.address.description
        }
        return nil
    }
    
    func generateSegwitAddress(_ derivation: Int) -> String? {
        #if DEV
        let btcNetwork: INetwork = BTCTestNet()
        let ltcNetwork: INetwork = LTCTestNet()
        #else
        let btcNetwork: INetwork = BTCTestNet()
        let ltcNetwork: INetwork = LTCTestNet()
        #endif
        let network: INetwork = wallet?.coin == .bitcoin ? btcNetwork : ltcNetwork
        let account = 0

        let scriptConverter = ScriptConverter()
        let segwitConverter =  SegWitBech32AddressConverter(prefix: network.bech32PrefixPattern, scriptConverter: scriptConverter)

        guard let mnemonic = KeychainWrapper.standart.getMnemonic() else { return nil }
        let seed = Mnemonic.seed(mnemonic: mnemonic)
        let hdWallet = SegwitHDWallet(seed: seed, coinType: network.coinType, xPrivKey: network.xPrivKey, xPubKey: network.xPubKey)
        do {
            let publicKey = try hdWallet.publicKey(account: account, index: derivation, external: true)
            print(publicKey.keyHash.hex)
            print(publicKey.scriptHashForP2WPKH.hex)
            print(publicKey.raw.hex)
            let add = try segwitConverter.convert(publicKey: publicKey, type: .p2wpkh)
            return add.stringValue
        } catch {
            print(error.localizedDescription)
            print("")
        }
        return nil
    }
    
    func setUpUI() {
        
        if let address = address {
            addressLabel.text = address
            generateQR(address: address)
        }
    }
    
    func generateQR(address: String) {
        let image = QRCodeGenerator().generate(from: address)
        qrImage.image = image
    }
    
    @objc func share() {
        guard let address = address else { return }
        let activity = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        activity.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width - 35, y: 50, width: 5, height: 5)
        
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func generateNewAction(_ sender: Any) {
        derivation += 1
        if let address = getAddressForDerivation(derivation), let walletId = wallet?.id {
            NetworkManager.derivation(derivation, address: address, walletId: walletId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error)
                    }
                    if success {
                        self?.address = address
                    }
                }
            }
        }
    }
    @IBAction func generateSegwitAddress(_ sender: Any) {
        derivation += 1
        if let address = generateSegwitAddress(derivation),
            let walletId = wallet?.id {
            NetworkManager.derivation(derivation, address: address, walletId: walletId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError(error)
                    }
                    if success {
                        self?.address = address
                    }
                }
            }
            
        }
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        guard let address = address else { return }
        UIPasteboard.general.string = address
        copyButton.isHidden = true
        copiedButton.isHidden = false
    }
    
    @IBAction func doneAction(_ sender: Any) {
        goBack()
    }
}
