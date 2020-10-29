//
//  ReferralViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.06.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ReferralViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var payoutView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!
    
    let inviteFriendView = InviteFriendView(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 370))
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpHomeNavBar(title: "SETTINGS_REFER_EARN")
        
        balanceView.drawShadow()
        payoutView.drawShadow()
        inviteFriendView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        getInfo()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func getInfo() {
        NetworkManager.getReferralInfo { [weak self] (info, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let info = info {
                    ApplicationManager.referralInfo = info
                    self?.earnedLabel.text = "$\(info.earned)"
                    self?.balanceLabel.text = "$\(info.balance)"
                    self?.inviteFriendView.code = info.id
                    self?.inviteFriendView.link = info.appReferralLink
                }
            }
        }
    }
    
    override func handleDismiss() {
        hideInviteFriendView()
    }
    
    func showInviteFriendView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(inviteFriendView)
        inviteFriendView.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor, constant: 12).isActive = true
        blackView.trailingAnchor.constraint(equalTo: inviteFriendView.trailingAnchor, constant: 12).isActive = true
        bottomConstraint = blackView.bottomAnchor.constraint(equalTo: inviteFriendView.bottomAnchor, constant: 30)
        bottomConstraint?.isActive = true
        inviteFriendView.heightAnchor.constraint(equalToConstant: 370).isActive = true
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideInviteFriendView() {
        bottomConstraint?.constant = -400
        UIView.animate(withDuration: 0.3, animations: {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }) { (_) in
            self.inviteFriendView.removeFromSuperview()
        }
    }
    
    @IBAction func viewDetails(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .referral).get(controller: .detailsVC) as? ReferralDetailsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func howItWorks(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .referral).get(controller: .howItWorksVC) as? HowItWorksViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func tellFriend(_ sender: Any) {
        showInviteFriendView()
    }
    @IBAction func requestPayout(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .referral).get(controller: .payoutVC) as? PayoutViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ReferralViewController: InviteFriendViewDelegate {
    func shareLink(_ link: String) {
        let activity = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        activity.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width - 35, y: 50, width: 5, height: 5)
        
        self.present(activity, animated: true, completion: nil)
    }
}
