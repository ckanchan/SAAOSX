//
//  OnlineViewController.swift
//  SAAiOS-New
//
//  Created by Chaitanya Kanchan on 06/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import WebKit

class OnlineViewController: UIViewController, WKUIDelegate {
    var url: URL!
    var webView: WKWebView!

    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        let request = URLRequest(url: url)
        webView.load(request)
        navigationItem.title = webView.title ?? webView.url?.absoluteString ?? "Oracc Web"
    }

}
