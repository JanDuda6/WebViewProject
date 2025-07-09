//
//  MainViewController.swift
//  WebViewProject
//
//  Created by Jan Duda on 08/07/2025.
//

import AVFoundation
import UIKit
import WebKit

class MainViewController: UIViewController {
    private let viewModel = MainViewModel()

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        loader.color = .gray
        return loader
    }()

    private let messageView: MessageView = {
        let view = MessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        bindViewModel()
        loadWebView()
        viewModel.startMonitoringNetwork()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private func prepareViews() {
        view.backgroundColor = .white
        view.addSubview(webView)
        view.addSubview(messageView)
        webView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),

            messageView.topAnchor.constraint(equalTo: webView.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            messageView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
        ])

        messageView.delegate = self
    }

    private func bindViewModel() {
        viewModel.onStatusUpdate = { [weak self] state in
            self?.messageView.updateView(for: state)
        }
    }

    private func loadWebView() {
        if let url = URL(string: viewModel.initialAppURL) {
            activityIndicator.startAnimating()
            webView.load(URLRequest(url: url))
        }
    }

    private func reloadWebView() {
        activityIndicator.startAnimating()
        webView.reload()
    }

    @objc private func appDidBecomeActive() {
        viewModel.handleAppDidBecomeActive()
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        viewModel.checkLoginState(for: webView.url)
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

        // check for another error than no connection. No connection is handle in viewModel method
        if nsError.domain == NSURLErrorDomain && nsError.code != NSURLErrorNotConnectedToInternet {
            messageView.updateView(for: .error)
            print("did fail prov")
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        messageView.updateView(for: .error)
        activityIndicator.stopAnimating()
        print("did fail")
    }
}

extension MainViewController: WKUIDelegate {
    // Handle Camera permission
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        let allowedDomain = "infakt.pl"
        let host = origin.host.lowercased()

        if host.hasSuffix(allowedDomain), type == .camera {
            decisionHandler(.grant)
        } else {
            decisionHandler(.deny)
        }
    }
}

extension MainViewController: MessageViewDelegate {
    func didTapButton() {
        reloadWebView()
    }
}
