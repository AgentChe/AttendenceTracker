//
//  CourseView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit

final class CourseView: UIView {
    lazy var tableView = makeTableView()
    lazy var emptyView = makeEmptyView()
    lazy var createAttendanceButton = makeCreateAttendanceButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension CourseView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
}

// MARK: Make constraints
private extension CourseView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: createAttendanceButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            createAttendanceButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            createAttendanceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            createAttendanceButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            createAttendanceButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CourseView {
    func makeTableView() -> CourseTableView {
        let view = CourseTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmptyView() -> CourseEmptyView {
        let view = CourseEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateAttendanceButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Course.CreateAttendance".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
