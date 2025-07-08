//
//  MainViewController.swift
//  WebViewProject
//
//  Created by Jan Duda on 08/07/2025.
//

import LocalAuthentication
import Network
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
        checkInternetConnection()
        prepareNotifications()
        view.backgroundColor = .white
        messageView.delegate = self
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

        webView.addSubview(messageView)
        NSLayoutConstraint.activate([
            messageView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            messageView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            messageView.topAnchor.constraint(equalTo: webView.topAnchor),
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

    private func checkInternetConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.messageView.updateView(for: .hidden)
                    self?.webView.reload()
                } else {
                    self?.messageView.updateView(for: .noInternet)
                }
            }
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
        messageView.updateView(for: .hidden)
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        messageView.updateView(for: .hidden)
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError

        // check for another error than no connection. No connection is handle in checkInternetConnection() method with reaction to connection reached
        if nsError.domain == NSURLErrorDomain && nsError.code != NSURLErrorNotConnectedToInternet {
            messageView.updateView(for: .error)
            print("@@@ Provisional navigation failed: \(nsError.localizedDescription)")
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        messageView.updateView(for: .error)
        activityIndicator.stopAnimating()
        print("@@@ load did fail with error: \(error)")
    }
}

// MARK: - MessageView

extension MainViewController: MessageViewDelegate {
    func didTapButton() {
        webView.reload()
    }
}
