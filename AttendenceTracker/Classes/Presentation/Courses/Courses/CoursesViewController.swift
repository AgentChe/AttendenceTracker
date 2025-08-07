//
//  CoursesViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit
import RxSwift

final class CoursesViewController: UIViewController {
    private lazy var mainView = CoursesView()
    
    private lazy var viewModel = CoursesViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: CoursesViewModel.Input(
            didTapAddCourse: mainView.addCourseButton.rx.tap.asSignal(),
            didDelete: mainView.tableView.didDelete,
            didSelect: mainView.tableView.didSelect
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
extension CoursesViewController {
    static func make() -> CoursesViewController {
        let vc = CoursesViewController()
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension CoursesViewController {
    func action(_ action: CoursesViewModel.Action) {
        switch action {
        case .createCourse:
            let vc = CreateCourseViewController.make()
            navigationController?.pushViewController(vc, animated: true)
        case .openCourse(let course):
            let vc = CourseViewController.make(course: course)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
