//
//  MainViewController.swift
//  WebViewProject
//
//  Created by Jan Duda on 07/07/2025.
//

import LocalAuthentication
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
    
    private let messageView: MessageView = {
        let template = MessageView()
        template.translatesAutoresizingMaskIntoConstraints = false
        return template
    }()
    
    private var isLoggedIn = false

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
    
    private func prepareNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func appWillEnterForeground() {
        if isLoggedIn {
            messageView.updateView(for: .faceID)
            authenticateUserWithFaceID()
        }
    }

    private func loadWebView() {
        if let url = URL(string: "https://konto.infakt.pl") {
            let request = URLRequest(url: url)
            activityIndicator.startAnimating()
            webView.load(request as URLRequest)
        }
    }
    
    private func authenticateUserWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Auth with FaceID") { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.messageView.updateView(for: .hidden)
                    }
                }
            }
        }
    }
}

// MARK: - WebView

extension MainViewController: WKNavigationDelegate {
    
    // Handle Camera permission
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
    // Handle log in state
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let urlString = webView.url?.absoluteString else { return }
        if urlString.contains("konto") {
            isLoggedIn = false
        } else if urlString.contains("front") {
            isLoggedIn = true
        }
    }

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
