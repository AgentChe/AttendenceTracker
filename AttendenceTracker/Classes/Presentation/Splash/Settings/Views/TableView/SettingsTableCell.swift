//
//  SettingsTableCell.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit

final class SettingsTableCell: UITableViewCell {
    lazy var label = makeLabel()
    lazy var chevronView = makeChevronView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.IBMPlexSans.medium(size: 16.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SettingsTableCell {
    func setup(element: SettingsTableElement) {
        label.attributedText = element.title.attributed(with: attrs)
    }
}

// MARK: Private
private extension SettingsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SettingsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            chevronView.widthAnchor.constraint(equalToConstant: 24.scale),
            chevronView.heightAnchor.constraint(equalToConstant: 24.scale),
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            chevronView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsTableCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeChevronView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Arrow.Right")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}

// MARK: Additional
private extension SettingsTableElement {
    var title: String {
        switch self {
        case .statuses:
            return "Settings.Statuses".localized
        case .termsOfUse:
            return "Settings.TermsOfUse".localized
        case .privacyPolicy:
            return "Settings.PrivacyPolicy".localized
        case .contactUs:
            return "Settings.ContactUs".localized
        }
    }
}
