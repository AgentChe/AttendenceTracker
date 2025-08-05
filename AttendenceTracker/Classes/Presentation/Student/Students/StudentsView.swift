//
//  StudentsView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentsView: UIView {
    lazy var tableView = makeTableView()
    lazy var emptyView = makeEmptyView()
    lazy var addStudentButton = makeAddStudentButton()
    
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
private extension StudentsView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
}

// MARK: Make constraints
private extension StudentsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: addStudentButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addStudentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            addStudentButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            addStudentButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            addStudentButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension StudentsView {
    func makeTableView() -> StudentsTableView {
        let view = StudentsTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmptyView() -> StudentsEmptyView {
        let view = StudentsEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAddStudentButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Students.Add".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
