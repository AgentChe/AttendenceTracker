//
//  CreateStudentNoteViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift

final class CreateStudentNoteViewController: UIViewController {
    private let mainView: CreateStudentNoteView
    
    private let viewModel: CreateStudentNoteViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(student: Student) {
        mainView = CreateStudentNoteView(student: student)
        viewModel = CreateStudentNoteViewModel(student: student)
        
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
        
        let output = viewModel.configure(input: CreateStudentNoteViewModel.Input(
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
extension CreateStudentNoteViewController {
    static func make(student: Student) -> CreateStudentNoteViewController {
        let vc = CreateStudentNoteViewController(student: student)
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
private extension CreateStudentNoteViewController {
    func action(_ action: CreateStudentNoteViewModel.Action) {
        switch action {
        case .close:
            dismiss(animated: true)
        }
    }
}
