//
//  CourseViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift

final class CourseViewController: UIViewController {
    private lazy var mainView = CourseView()
    
    private let viewModel: CourseViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private init(course: Course) {
        viewModel = CourseViewModel(course: course)
        
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
        
        let output = viewModel.configure(input: CourseViewModel.Input(
            didTapAddAttendance: mainView.createAttendanceButton.rx.tap.asSignal(),
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
extension CourseViewController {
    static func make(course: Course) -> CourseViewController {
        let vc = CourseViewController(course: course)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = course.name
        return vc
    }
}

// MARK: Private
private extension CourseViewController {
    func action(_ action: CourseViewModel.Action) {
        switch action {
        case .createAttendance(let course):
            let vc = CreateAttendanceViewController.make(course: course)
            present(vc, animated: true)
        case .openAttendance(let attendance):
            let vc = AttendanceViewController.make(attendance: attendance)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
