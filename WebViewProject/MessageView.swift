//
//  MessageView.swift
//  WebViewProject
//
//  Created by Jan Duda on 08/07/2025.
//

import UIKit

enum MessageViewState {
    case faceID, hidden
}

class MessageView: UIView {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let background: UIView = {
        let background = UIView()
        background.backgroundColor = .lightGray
        background.layer.cornerRadius = 20
        background.translatesAutoresizingMaskIntoConstraints = false
        return background
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.image = UIImage(systemName: "faceid")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        prepareView()
        prepareFaceIDView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func updateView(for state: MessageViewState) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch state {
        case .faceID:
            stackView.addArrangedSubview(background)
            isHidden = false
        case .hidden:
            isHidden = true
        }
    }

    private func prepareView() {
        isHidden = true

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    private func prepareFaceIDView() {
        background.addSubview(imageView)

        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalToConstant: 100),
            background.heightAnchor.constraint(equalToConstant: 100),
            imageView.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
