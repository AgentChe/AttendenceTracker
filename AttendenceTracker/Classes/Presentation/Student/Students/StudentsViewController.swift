//
//  StudentsViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift

final class StudentsViewController: UIViewController {
    private lazy var mainView = StudentsView()
    
    private lazy var viewModel = StudentsViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: StudentsViewModel.Input(
            didTapCreateStudent: mainView.addStudentButton.rx.tap.asSignal(),
            didSelect: mainView.tableView.didSelect,
            didDelete: mainView.tableView.didDelete
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView) { base, elements in
                base.tableView.setup(elements: elements)
                base.emptyView.isHidden = !elements.isEmpty
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension StudentsViewController {
    static func make() -> StudentsViewController {
        let vc = StudentsViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension StudentsViewController {
    func action(_ action: StudentsViewModel.Action) {
        switch action {
        case .createStudent:
            let vc = CreateStudentViewController.make()
            present(vc, animated: true)
        case .openStudent(let student):
            let vc = StudentNotesViewController.make(student: student)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
