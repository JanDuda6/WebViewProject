//
//  MessageView.swift
//  WebViewProject
//
//  Created by Jan Duda on 08/07/2025.
//

import UIKit

protocol MessageViewDelegate: AnyObject {
    func didTapButton()
}

enum MessageViewState {
    case faceID, hidden, noInternet, error
}

class MessageView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try again", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 160).isActive = true
        button.backgroundColor = .gray
        return button
    }()

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

    weak var delegate: MessageViewDelegate?

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
        case .noInternet:
            stackView.addArrangedSubview(messageLabel)
            messageLabel.text = "No internet connection. Try again later."
            isHidden = false
        case .error:
            stackView.addArrangedSubview(messageLabel)
            stackView.addArrangedSubview(retryButton)
            messageLabel.text = "Something went wrong"
            isHidden = false
        }
    }

    private func prepareView() {
        isHidden = true
        addSubview(stackView)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
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

    @objc func retryTapped() {
        delegate?.didTapButton()
    }
}
