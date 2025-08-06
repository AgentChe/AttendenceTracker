//
//  CreateCourseView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit
import RxSwift

final class CreateCourseView: UIView {
    lazy var nameField = makeNameField()
    lazy var separator = makeSeparator()
    lazy var tableView = makeTableView()
    lazy var saveButton = makeSaveButton()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextFieldDelegate
extension CreateCourseView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: Private
private extension CreateCourseView {
    func initialize() {
        backgroundColor = Appearance.mono100
        
        tableView.rx.willBeginDragging
            .bind(to: rx.hideKeyboardObserver)
            .disposed(by: disposeBag)
    }
}

// MARK: Make constraints
private extension CreateCourseView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            nameField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 54.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CreateCourseView {
    func makeNameField() -> PaddingTextField {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.mono200.withAlphaComponent(0.5))
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        let textAttrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = PaddingTextField()
        view.textPadding = UIEdgeInsets(vertical: 8.scale, horizontal: 16.scale)
        view.defaultTextAttributes = textAttrs.dictionary
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.layer.borderColor = Appearance.mono200.withAlphaComponent(0.2).cgColor
        view.layer.borderWidth = 1.scale
        view.attributedPlaceholder = "CreateCourse.Name.Placeholder".localized.attributed(with: placeholderAttrs)
        view.borderStyle = .none
        view.delegate = self
        view.keyboardType = .namePhonePad
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono200.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> CreateCourseTableView {
        let view = CreateCourseTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSaveButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 8.scale
        view.backgroundColor = Appearance.main100
        view.setAttributedTitle("Save".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
