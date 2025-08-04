//
//  CreateStatusView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateStatusView: UIView {
    lazy var textField = makeTextField()
    
    private lazy var textFieldBottomConstraint = NSLayoutConstraint()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapCreateTrigger = PublishRelay<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeContraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateStatusView {
    var didTapCreate: Signal<String> {
        didTapCreateTrigger.asSignal()
    }
}

// MARK: UITextFieldDelegate
extension CreateStatusView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cleaned = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleaned.isEmpty else {
            return false
        }
        
        defer {
            didTapCreateTrigger.accept(cleaned)
        }
        
        return true
    }
}

// MARK: Private
private extension CreateStatusView {
    func initialize() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 24.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        rx.keyboardHeight
            .asDriver(onErrorDriveWith: .never())
            .drive(Binder(self) { base, keyboardHeight in
                let show = keyboardHeight > 0
                base.textFieldBottomConstraint.constant = show ? (-keyboardHeight - 8.scale) : -16.scale
                
                UIView.animate(withDuration: 0.3, animations: {
                    base.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make constraints
private extension CreateStatusView {
    func makeContraints() {
        textFieldBottomConstraint = textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16.scale)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textField.heightAnchor.constraint(equalToConstant: 44.scale),
            textFieldBottomConstraint
        ])
    }
}

// MARK: Lazy initialization
private extension CreateStatusView {
    func makeTextField() -> PaddingTextField {
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
        view.returnKeyType = .continue
        view.attributedPlaceholder = "CreateStatus.Placeholder".localized.attributed(with: placeholderAttrs)
        view.borderStyle = .none
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
