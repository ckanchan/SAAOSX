//
//  OnlineViewController.swift
//  SAAiOS-New
//
//  Created by Chaitanya Kanchan on 06/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import WebKit

class OnlineViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var url: URL!
    var webView: WKWebView!
    var progressView: UIProgressView!

    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        
        progressView = UIProgressView(progressViewStyle: .default)
        let progressButton = UIBarButtonItem(customView: progressView)
        self.setToolbarItems([progressButton], animated: true)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let request = URLRequest(url: url)
        webView.load(request)
        navigationItem.title = webView.title ?? webView.url?.absoluteString ?? "Oracc Web"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Unable to load page", message: "Unable to reach server: \(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Go back", style: .default){ _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
