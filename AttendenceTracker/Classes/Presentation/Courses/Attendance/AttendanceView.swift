//
//  AttendanceView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit

final class AttendanceView: UIView {
    lazy var tableView = makeTableView()
    lazy var emailReportButton = makeEmailReportButton()
    
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
private extension AttendanceView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
}

// MARK: Make constraints
private extension AttendanceView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: emailReportButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            emailReportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            emailReportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            emailReportButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            emailReportButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AttendanceView {
    func makeTableView() -> AttendanceTableView {
        let view = AttendanceTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmailReportButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Attendance.EmailReport".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
