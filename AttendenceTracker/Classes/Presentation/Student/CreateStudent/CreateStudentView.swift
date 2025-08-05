//
//  CreateStudentView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateStudentView: UIView {
    struct Data {
        let firstName: String
        let lastName: String
        let email: String
    }
    
    lazy var firstNameField = makeFirstNameField()
    lazy var lastNameField = makeLastNameField()
    lazy var emailField = makeEmailField()
    lazy var createButton = makeCreateButton()
    
    private lazy var createButtonBottomConstraint = NSLayoutConstraint()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeContraints()
        initialize()
        textEditing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateStudentView {
    var didTapCreate: Signal<Data> {
        createButton.rx.tap
            .compactMap { [weak self] void -> Data? in
                guard let self else { return nil }
                
                return Data(
                    firstName: firstNameField.text ?? "",
                    lastName: lastNameField.text ?? "",
                    email: emailField.text ?? ""
                )
            }
            .asSignal(onErrorSignalWith: .never())
    }
}

// MARK: UITextFieldDelegate
extension CreateStudentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: Private
private extension CreateStudentView {
    func initialize() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 24.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        rx.keyboardHeight
            .asDriver(onErrorDriveWith: .never())
            .drive(Binder(self) { base, keyboardHeight in
                let show = keyboardHeight > 0
                base.createButtonBottomConstraint.constant = show ? (-keyboardHeight - 8.scale) : -16.scale
                
                UIView.animate(withDuration: 0.3, animations: {
                    base.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    func textEditing() {
        let firstNameNotEmpty = !(firstNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let lastNameNotEmpty = !(lastNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailNameNotEmpty = !(emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let notEmpty = firstNameNotEmpty && lastNameNotEmpty && emailNameNotEmpty
        
        createButton.alpha = notEmpty ? 1 : 0.5
        createButton.isEnabled = notEmpty
    }
}

// MARK: Make constraints
private extension CreateStudentView {
    func makeContraints() {
        NSLayoutConstraint.activate([
            firstNameField.heightAnchor.constraint(equalToConstant: 44.scale),
            firstNameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            firstNameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            firstNameField.bottomAnchor.constraint(equalTo: lastNameField.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            lastNameField.heightAnchor.constraint(equalToConstant: 44.scale),
            lastNameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            lastNameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            lastNameField.bottomAnchor.constraint(equalTo: emailField.topAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            emailField.heightAnchor.constraint(equalToConstant: 44.scale),
            emailField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            emailField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            emailField.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16.scale)
        ])
        
        createButtonBottomConstraint = createButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale)
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            createButton.heightAnchor.constraint(equalToConstant: 54.scale),
            createButtonBottomConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension CreateStudentView {
    func makeFirstNameField() -> PaddingTextField {
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
        view.attributedPlaceholder = "CreateStudent.FirstName".localized.attributed(with: placeholderAttrs)
        view.borderStyle = .none
        view.delegate = self
        view.keyboardType = .namePhonePad
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(textEditing), for: .editingChanged)
        addSubview(view)
        return view
    }
    
    func makeLastNameField() -> PaddingTextField {
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
        view.attributedPlaceholder = "CreateStudent.LastName".localized.attributed(with: placeholderAttrs)
        view.borderStyle = .none
        view.delegate = self
        view.keyboardType = .namePhonePad
        view.addTarget(self, action: #selector(textEditing), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeEmailField() -> PaddingTextField {
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
        view.attributedPlaceholder = "CreateStudent.Email".localized.attributed(with: placeholderAttrs)
        view.borderStyle = .none
        view.delegate = self
        view.keyboardType = .emailAddress
        view.addTarget(self, action: #selector(textEditing), for: .editingChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCreateButton() -> UIButton {
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
