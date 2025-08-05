//
//  StudentNotesViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift

final class StudentNotesViewController: UIViewController {
    private lazy var mainView = StudentNotesView()
    
    private let viewModel: StudentNotesViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var addNoteButton = TapAreaButton()
    
    private init(student: Student) {
        viewModel = StudentNotesViewModel(student: student)
        
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
        
        addCreateNoteButton()
        
        let output = viewModel.configure(input: StudentNotesViewModel.Input(
            didTapAddNote: addNoteButton.rx.tap.asSignal(),
            didDelete: mainView.tableView.didDelete,
            didTapEmailReport: mainView.emailReportButton.rx.tap.asSignal(),
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
extension StudentNotesViewController {
    static func make(student: Student) -> StudentNotesViewController {
        let vc = StudentNotesViewController(student: student)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = String(format: "%@ %@", student.firstName, student.lastName)
        return vc
    }
}

// MARK: Private
private extension StudentNotesViewController {
    func action(_ action: StudentNotesViewModel.Action) {
        switch action {
        case .createNote(let student):
            let vc = CreateStudentNoteViewController.make(student: student)
            present(vc, animated: true)
        case .openNote(let note):
            let vc = StudentNoteViewController.make(studentNote: note)
            present(vc, animated: true)
        }
    }
    
    func addCreateNoteButton() {
        addNoteButton.backgroundColor = UIColor.clear
        addNoteButton.setImage(UIImage(named: "Add"), for: .normal)
        
        let item = UIBarButtonItem(customView: addNoteButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
}
