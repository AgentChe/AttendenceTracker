//
//  CreateAttendanceView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit

final class CreateAttendanceView: UIView {
    lazy var datePicker = makeDatePicker()
    lazy var doneButton = makeDoneButton()
    
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
private extension CreateAttendanceView {
    func initialize() {
        backgroundColor = UIColor.gray
        layer.cornerRadius = 24.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}

// MARK: Make constraints
private extension CreateAttendanceView {
    func makeContraints() {
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 31.scale),
            doneButton.widthAnchor.constraint(equalToConstant: 100.scale),
            doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 8.scale),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateAttendanceView {
    func makeDatePicker() -> UIDatePicker {
        let view = UIDatePicker()
        view.datePickerMode = .dateAndTime
        view.preferredDatePickerStyle = .wheels
        view.locale = Locale.current
        view.date = Date()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeDoneButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let button = UIButton()
        button.setAttributedTitle("Done".localized.attributed(with: attrs), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 8.scale
        addSubview(button)
        return button
    }
}
