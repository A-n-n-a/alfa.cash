//
//  SpeedView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 05.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol SpeedViewDelegate {
    func addressSelected(_ address: String)
    func speedSelected()
}

class SpeedView: UIView {
    
    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var tableView: UITableView!
    
    var mode: SpeedViewMode = .speed {
        didSet {
            setTitle()
            tableView.reloadData()
        }
    }
    var delegate: SpeedViewDelegate?
    var metas: [Meta]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var fee: String?
    var files: [String]? {
        didSet {
            tableView.reloadData()
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
        let nib =  UINib(nibName: "SpeedView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: SpeedTableViewCell.self)
        
        
    }
    
    func updateContent() {
        tableView.reloadData()
    }
    
    func setTitle() {
        var title = ""
        switch mode {
        case .addresses:
            title = "SELECT_ADDRESS"
        case .iCloud:
            title = "ICLOUD_CHOOSE_MNEMONIC"
        case .speed:
            title = "SELECT_NETWORK_SPEED"
        }
        titleLabel.setText(title)
    }
}

extension SpeedView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .speed:
            return metas?.count ?? 1
        case .addresses:
            return min(3, WalletManager.recentAddresses.count)
        case .iCloud:
            return files?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpeedTableViewCell.self), for: indexPath) as! SpeedTableViewCell
        cell.delegate = self
        switch mode {
        case .speed:
            if let meta = metas?[indexPath.row], let speed = Speed(rawValue: meta.value) {
                let fee = meta.fee
                cell.setSpeed(speed, fee: fee)
            }
        case .addresses:
            cell.address = WalletManager.recentAddresses[indexPath.row]
        case .iCloud:
            if let files = files {
                var nameElements = files[indexPath.row].components(separatedBy: ".")
                var mnemonic = nameElements.first
                if mnemonic?.isEmpty ?? true {
                    nameElements = Array(nameElements.dropFirst())
                    mnemonic = nameElements.first
                }
                cell.address = mnemonic
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as? SpeedTableViewCell
        cell?.selection()
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch mode {
        case .speed:
            switch indexPath.row {
            case 0:
                WalletManager.selectedSpeed = .slow
            case 1:
                WalletManager.selectedSpeed = .medium
            case 2:
                WalletManager.selectedSpeed = .fast
            default:
                break
            }
            if let meta = metas?[indexPath.row] {
                TransactionManager.speed = WalletManager.selectedSpeed
                TransactionManager.transactionHeaders.fee = meta.fee
                TransactionManager.transactionHeaders.total = meta.total
                delegate?.speedSelected()
            }
            tableView.reloadData()
        case .addresses:
            delegate?.addressSelected(WalletManager.recentAddresses[indexPath.row])
        case .iCloud:
            if let files = files {
                delegate?.addressSelected(files[indexPath.row])
            }
        }
    }
}

extension SpeedView: SpeedTableViewCellDelegate {
    
}

enum SpeedViewMode {
    case speed
    case addresses
    case iCloud
}
