//
//  WebViewViewController.swift
//
//
//  Created by Anna on 3/13/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: BaseViewController {
    
    var screenTitle = String()
    var webView = WKWebView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpHomeNavBar(title: screenTitle)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        
        self.navigationController?.navigationBar.barStyle = .black
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func loadView() {

        webView.navigationDelegate = self
        view = webView
        webView.addSubview(activityIndicator)
       activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
                                     activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)])
        activityIndicator.startAnimating()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
        self.showError(error as AnyObject)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
    {
        print("URL: ", navigationAction.request.url!.absoluteString)
        if let url = navigationAction.request.url, url.absoluteString.contains("referral/callback") {
            self.navigationController?.popViewController(animated: true)
            
        }
        decisionHandler(.allow)
    }
}
