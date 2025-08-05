//
//  CreateStudentNoteView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateStudentNoteView: UIView {
    lazy var placeholderLabel = makePlaceholderLabel()
    lazy var textView = makeTextField()
    lazy var createButton = makeCreateButton()
    
    private lazy var createButtonBottomConstraint = NSLayoutConstraint()
    
    private lazy var disposeBag = DisposeBag()
    
    private let student: Student
    
    init(student: Student) {
        self.student = student
        
        super.init(frame: .zero)
        
        makeContraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateStudentNoteView {
    var didTapCreate: Signal<String> {
        createButton.rx.tap
            .compactMap { [weak self] void -> String? in
                guard let self else { return nil }
                
                let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                return text.isEmpty ? nil : text
            }
            .asSignal(onErrorSignalWith: .never())
    }
}

// MARK: Private
private extension CreateStudentNoteView {
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
}

// MARK: Make constraints
private extension CreateStudentNoteView {
    func makeContraints() {
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textView.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 8.scale),
            textView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16.scale)
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
private extension CreateStudentNoteView {
    func makePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
            .lineBreakMode(.byTruncatingTail)
        
        let name = String(format: "%@ %@", student.firstName, student.lastName)
        let string = String(format: "CreateStudentNote.Placeholder".localized, name)
        
        let view = UILabel()
        view.attributedText = string.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextField() -> UITextView {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UITextView()
        view.typingAttributes = attrs.dictionary
        view.textContainerInset = UIEdgeInsets(value: 8.scale)
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 8.scale
        view.layer.masksToBounds = true
        view.layer.borderColor = Appearance.mono200.withAlphaComponent(0.2).cgColor
        view.layer.borderWidth = 1.scale
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
