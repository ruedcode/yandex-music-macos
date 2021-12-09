//
//  WebView.swift
//  YandexMusic
//
//  Created by Eugene Kalyada on 27.11.2021.
//  Copyright © 2021 Eugene Kalyada. All rights reserved.
//

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false
    @Published var pageTitle: String

    init (link: String) {
        self.link = link
        self.pageTitle = ""
    }
}

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {

    public typealias NSViewType = WKWebView

    private let webView: WKWebView = WKWebView()

    @ObservedObject var viewModel: WebViewModel
    var withResetCookies: Bool = false

    public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        if withResetCookies {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { items in
                items.forEach { webView.configuration.websiteDataStore.httpCookieStore.delete($0, completionHandler: nil) }
                webView.load(URLRequest(url: URL(string: viewModel.link)!))
            }
        } else {
            webView.load(URLRequest(url: URL(string: viewModel.link)!))
        }
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebView>) { }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
           //Initialise the WebViewModel
           self.viewModel = viewModel
        }

        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }

        //After the webpage is loaded, assign the data in WebViewModel class
        public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
            self.viewModel.pageTitle = web.title!
            self.viewModel.link = web.url?.absoluteString ?? ""
            self.viewModel.didFinishLoading = true
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

    }

}
