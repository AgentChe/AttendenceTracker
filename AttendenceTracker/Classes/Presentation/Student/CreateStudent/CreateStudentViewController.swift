//
//  CreateStudentViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift

final class CreateStudentViewController: UIViewController {
    private lazy var mainView = CreateStudentView()
    
    private lazy var viewModel = CreateStudentViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: CreateStudentViewModel.Input(
            didCreate: mainView.didTapCreate
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension CreateStudentViewController {
    static func make() -> CreateStudentViewController {
        let vc = CreateStudentViewController()
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small"), resolver: { _ in 266.scale })]
            sheet.selectedDetentIdentifier = .init("small")
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24.scale
        }
        
        return vc
    }
}

// MARK: Private
private extension CreateStudentViewController {
    func action(_ action: CreateStudentViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
