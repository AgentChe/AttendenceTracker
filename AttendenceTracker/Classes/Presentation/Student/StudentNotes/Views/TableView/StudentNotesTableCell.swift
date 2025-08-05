//
//  StudentNotesTableCell.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentNotesTableCell: UITableViewCell {
    lazy var label = makeLabel()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.IBMPlexSans.regular(size: 16.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
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
extension StudentNotesTableCell {
    func setup(element: StudentNote) {
        let date = dateFormatter.string(from: Date(timeIntervalSince1970: element.createdAt))
        let string = String(format: "%@\n%@", date, element.text)
        label.attributedText = string.attributed(with: attrs)
    }
}

// MARK: Private
private extension StudentNotesTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension StudentNotesTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension StudentNotesTableCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
