//
//  CreateCourseCell.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit

final class CreateCourseCell: UITableViewCell {
    lazy var label = makeLabel()
    lazy var checkedView = makeCheckedView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.IBMPlexSans.regular(size: 16.scale))
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
extension CreateCourseCell {
    func setup(element: CreateCourseTableStudentElement) {
        let name = String(format: "%@ %@", element.student.firstName, element.student.lastName)
        label.attributedText = name.attributed(with: attrs)
        
        checkedView.isHidden = !element.checked
    }
    
    func setup(element: CreateCourseTableStatusElement) {
        label.attributedText = element.status.title.attributed(with: attrs)
        
        checkedView.isHidden = !element.checked
    }
}

// MARK: Private
private extension CreateCourseCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension CreateCourseCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            checkedView.widthAnchor.constraint(equalToConstant: 24.scale),
            checkedView.heightAnchor.constraint(equalToConstant: 24.scale),
            checkedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            checkedView.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateCourseCell {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCheckedView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Checked")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
