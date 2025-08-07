//
//  AttendanceTableNotesTitleCell.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit

final class AttendanceTableNotesTitleCell: UITableViewCell {
    var didTapAdd: (() -> Void)?
    
    lazy var label = makeLabel()
    lazy var addButton = makeAddButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AttendanceTableNotesTitleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func addTapped() {
        didTapAdd?()
    }
}

// MARK: Make constraints
private extension AttendanceTableNotesTitleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 24.scale),
            addButton.heightAnchor.constraint(equalToConstant: 24.scale),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            addButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AttendanceTableNotesTitleCell {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.semiBold(size: 18.scale))
            .lineHeight(23.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Attendance.Notes.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeAddButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Add"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        contentView.addSubview(view)
        return view
    }
}
