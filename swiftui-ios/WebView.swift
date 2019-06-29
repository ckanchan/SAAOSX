//
//  WebView.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 23/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI
import WebKit
import CDKSwiftOracc

struct WebView: UIViewRepresentable {
    var address: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView(frame: .zero)
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        let req = URLRequest(url: address)
        uiView.load(req)
    }

}

#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        let url = URL(string: "http://oracc.org/saao/P224485/html")!
        return WebView(address: url)
    }
}
#endif

