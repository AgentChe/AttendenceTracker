//
//  AttendanceViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class AttendanceViewController: UIViewController {
    private lazy var mainView = AttendanceView()
    
    private let viewModel: AttendanceViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didSelectNewStatusTrigger = PublishRelay<(Status, String)>()
    
    private init(attendance: Attendance) {
        viewModel = AttendanceViewModel(attendance: attendance)
        
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
        
        let output = viewModel.configure(input: AttendanceViewModel.Input(
            didDeleteNote: mainView.tableView.didDeleteNote,
            didSelectNote: mainView.tableView.didSelectNote,
            didTapAddNote: mainView.tableView.didTapAddNote,
            didTapChangeStatus: mainView.tableView.didTapChangeStatus,
            didSelectNewStatus: didSelectNewStatusTrigger.asSignal()
        ))
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AttendanceViewController {
    static func make(attendance: Attendance) -> AttendanceViewController {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        
        let vc = AttendanceViewController(attendance: attendance)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = dateFormatter.string(from: Date(timeIntervalSince1970: attendance.date))
        return vc
    }
}

// MARK: Private
private extension AttendanceViewController {
    func action(_ action: AttendanceViewModel.Action) {
        switch action {
        case .createNote(let attendance):
            let vc = CreateAttendanceNoteViewController.make(attendance: attendance)
            present(vc, animated: true)
        case .openNote(let attendanceNote):
            let vc = AttendanceNoteViewController.make(attendanceNote: attendanceNote)
            present(vc, animated: true)
        case .selectNewStatus(let statuses, let recordId):
            let actionSheet = UIAlertController(title: "Attendance.SelectNewStatus".localized, message: nil, preferredStyle: .actionSheet)
            
            statuses.forEach { status in
                let action = UIAlertAction(title: status.title, style: .default) { [weak self] action in
                    self?.didSelectNewStatusTrigger.accept((status, recordId))
                }
                actionSheet.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true)
        }
    }
}
