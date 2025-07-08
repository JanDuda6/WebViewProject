//
//  MainViewController.swift
//  WebViewProject
//
//  Created by Jan Duda on 07/07/2025.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        return configuration
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = self
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityLoader = UIActivityIndicatorView(style: .large)
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        activityLoader.hidesWhenStopped = true
        activityLoader.color = .gray
        return activityLoader
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        loadWebView()
        view.backgroundColor = .white
    }

    private func prepareViews() {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        webView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
        ])
    }

    private func loadWebView() {
        if let url = URL(string: "https://konto.infakt.pl") {
            let request = URLRequest(url: url)
            activityIndicator.startAnimating()
            webView.load(request as URLRequest)
        }
    }
}

// MARK: - WebView

extension MainViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("@@@ load did fail with error: \(error)")
    }
}
