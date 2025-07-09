//
//  Ne.swift
//  WebViewProject
//
//  Created by Jan Duda on 09/07/2025.
//

import Network

class NetworkMonitorService {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    func startMonitoring(_ onChange: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                onChange(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
