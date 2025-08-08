//
//  AttendanceTableRecordCell.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 08.08.2025.
//

import UIKit

final class AttendanceTableRecordCell: UITableViewCell {
    var didTapStatus: (() -> Void)?
    
    lazy var label = makeLabel()
    lazy var statusButton = makeStatusButton()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.IBMPlexSans.regular(size: 16.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var statusAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        .lineBreakMode(.byTruncatingTail)
    
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
extension AttendanceTableRecordCell {
    func setup(element: AttendanceTableRecordElement) {
        let name = String(format: "%@ %@", element.student.firstName, element.student.lastName)
        label.attributedText = name.attributed(with: attrs)
        
        let status = String(format: "%@ ►", element.status.title)
        statusButton.setAttributedTitle(status.attributed(with: statusAttrs), for: .normal)
    }
}

// MARK: Private
private extension AttendanceTableRecordCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func statusTapped() {
        didTapStatus?()
    }
}

// MARK: Make constraints
private extension AttendanceTableRecordCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: statusButton.leadingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            statusButton.widthAnchor.constraint(equalToConstant: 100.scale),
            statusButton.heightAnchor.constraint(equalToConstant: 31.scale),
            statusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            statusButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AttendanceTableRecordCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeStatusButton() -> UIButton {
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(statusTapped), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }
}
