//
//  StatusesView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit

final class StatusesView: UIView {
    lazy var defaultInfoLabel = makeDefaultInfoLabel()
    lazy var tableView = makeTableView()
    lazy var createStatusButton = makeCreateStatusButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeContraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension StatusesView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
}

// MARK: Make constraints
private extension StatusesView {
    func makeContraints() {
        NSLayoutConstraint.activate([
            defaultInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            defaultInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            defaultInfoLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: defaultInfoLabel.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: createStatusButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            createStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            createStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            createStatusButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            createStatusButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension StatusesView {
    func makeDefaultInfoLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Statuses.DefaultInfo".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> StatusesTableView {
        let view = StatusesTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateStatusButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Statuses.CreateStatus".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
