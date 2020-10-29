//
//  TermsAndPrivacyViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 21.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import WebKit

class TermsAndPrivacyViewController: BaseViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var legalType: LegalType!

    override func viewDidLoad() {
        super.viewDidLoad()

        let key = legalType == .privacy ? "PRIVACY_POLICY_TITLE" : "TERMS_OF_SERVICE_TITLE"
        setUpWhiteNavBarForLogin(title: key)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupWebView()
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        let link = legalType == .terms ? Constants.Link.terms : Constants.Link.policy
        if let url = URL(string: link), let request = WebViewManager.shared.createRequest(url) {
            activityIndicator.startAnimating()
            webView.load(request)
        }
    }
}

extension TermsAndPrivacyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        self.showError(error)
    }
}

enum LegalType {
    case privacy
    case terms
}
