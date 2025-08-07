//
//  CreateAttendanceNoteViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift

final class CreateAttendanceNoteViewController: UIViewController {
    private lazy var mainView = CreateAttendanceNoteView()
    
    private let viewModel: CreateAttendanceNoteViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(attendance: Attendance) {
        viewModel = CreateAttendanceNoteViewModel(attendance: attendance)
        
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
        
        let output = viewModel.configure(input: CreateAttendanceNoteViewModel.Input(
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
        
        mainView.textView.becomeFirstResponder()
    }
}

// MARK: Public
extension CreateAttendanceNoteViewController {
    static func make(attendance: Attendance) -> CreateAttendanceNoteViewController {
        let vc = CreateAttendanceNoteViewController(attendance: attendance)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small"), resolver: { _ in 241.scale })]
            sheet.selectedDetentIdentifier = .init("small")
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24.scale
        }
        
        return vc
    }
}

// MARK: Private
private extension CreateAttendanceNoteViewController {
    func action(_ action: CreateAttendanceNoteViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        }
    }
}
