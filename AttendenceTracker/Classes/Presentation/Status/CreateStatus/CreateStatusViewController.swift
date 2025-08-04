//
//  CreateStatusViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit
import RxSwift
import Toast_Swift

final class CreateStatusViewController: UIViewController {
    private lazy var mainView = CreateStatusView()
    
    private lazy var viewModel = CreateStatusViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: CreateStatusViewModel.Input(
            didCreate: mainView.didTapCreate
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.textField.becomeFirstResponder()
    }
}

// MARK: Public
extension CreateStatusViewController {
    static func make() -> CreateStatusViewController {
        let vc = CreateStatusViewController()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small"), resolver: { _ in 80.scale })]
            sheet.selectedDetentIdentifier = .init("small")
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24.scale
        }
        
        return vc
    }
}

// MARK: Private
private extension CreateStatusViewController {
    func action(_ action: CreateStatusViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        }
    }
}
