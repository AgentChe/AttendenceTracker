//
//  CreateAttendanceViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift

final class CreateAttendanceViewController: UIViewController {
    private lazy var mainView = CreateAttendanceView()
    
    private let viewModel: CreateAttendanceViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(course: Course) {
        viewModel = CreateAttendanceViewModel(course: course)
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let didCreate = mainView.doneButton.rx.tap
            .compactMap { [weak mainView] void -> Date? in
                mainView?.datePicker.date
            }
            .asSignal(onErrorSignalWith: .never())
        
        let output = viewModel.configure(input: CreateAttendanceViewModel.Input(
            didCreate: didCreate
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension CreateAttendanceViewController {
    static func make(course: Course) -> CreateAttendanceViewController {
        let vc = CreateAttendanceViewController(course: course)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small"), resolver: { _ in 210.scale })]
            sheet.selectedDetentIdentifier = .init("small")
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24.scale
        }
        
        return vc
    }
}

// MARK: Private
private extension CreateAttendanceViewController {
    func action(_ action: CreateAttendanceViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        }
    }
}
