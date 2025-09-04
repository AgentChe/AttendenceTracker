//
//  CreateCourseViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit
import RxSwift

final class CreateCourseViewController: UIViewController {
    private lazy var mainView = CreateCourseView()
    
    private lazy var viewModel = CreateCourseViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: CreateCourseViewModel.Input(
            didTapCreateStudent: mainView.tableView.didTapAddStudent,
            didTapCreateStatus: mainView.tableView.didTapAddStatus,
            didChangeSelectedStudent: mainView.tableView.didChangeSelectedStudent,
            didChangeSelectedStatus: mainView.tableView.didChangeSelectedStatus,
            didChangeCourseName: mainView.nameField.rx.text.map { $0 ?? "" }.asSignal(onErrorSignalWith: .never()),
            didTapSave: mainView.saveButton.rx.tap.asSignal()
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.saveEnable
            .drive(Binder(mainView.saveButton) { base, enable in
                base.isEnabled = enable
                base.alpha = enable ? 1 : 0.5
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension CreateCourseViewController {
    static func make() -> CreateCourseViewController {
        let vc = CreateCourseViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "CreateCourse.Title".localized
        return vc
    }
}

// MARK: Private
private extension CreateCourseViewController {
    func action(_ action: CreateCourseViewModel.Action) {
        switch action {
        case .createStudent:
            let vc = CreateStudentViewController.make()
            present(vc, animated: true)
        case .createStatus:
            let vc = CreateStatusViewController.make()
            present(vc, animated: true)
        case .close:
            navigationController?.popViewController(animated: true)
        case .openPaygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
