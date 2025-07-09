//
//  MainViewModel.swift
//  WebViewProject
//
//  Created by Jan Duda on 09/07/2025.
//

import Foundation

class MainViewModel {
    private let networkMonitorService: NetworkMonitorService
    private let faceIDService: FaceIDAuthService
    let initialAppURL = "https://konto.infakt.pl"

    var onStatusUpdate: ((MessageViewState) -> Void)?
    var isLoggedIn = false

    init(networkMonitorService: NetworkMonitorService = NetworkMonitorService(), faceIDService: FaceIDAuthService = FaceIDAuthService()) {
        self.networkMonitorService = networkMonitorService
        self.faceIDService = faceIDService
    }

    func startMonitoringNetwork() {
        networkMonitorService.startMonitoring { [weak self] isConnected in
            if isConnected {
                self?.onStatusUpdate?(.hidden)
            } else {
                self?.onStatusUpdate?(.noInternet)
            }
        }
    }

    func checkLoginState(for url: URL?) {
        guard let url = url?.absoluteString else { return }
        if url.contains("konto") {
            isLoggedIn = false
        } else if url.contains("front") {
            isLoggedIn = true
        }
    }

    func handleAppDidBecomeActive() {
        guard isLoggedIn else { return }
        onStatusUpdate?(.faceID)
        faceIDService.authenticate { [weak self] success in
            if success {
                self?.onStatusUpdate?(.hidden)
            }
        }
    }
}
