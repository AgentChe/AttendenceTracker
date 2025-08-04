//
//  StatusesViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit
import RxSwift
import Toast_Swift

final class StatusesViewController: UIViewController {
    private lazy var mainView = StatusesView()
    
    private lazy var viewModel = StatusesViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: StatusesViewModel.Input(
            didTapCreateStatus: mainView.createStatusButton.rx.tap.asSignal(),
            didLongPressStatus: mainView.tableView.didLongPress,
            didDeleteStatus: mainView.tableView.didDelete,
            didAttemptDeleteSystemStatus: mainView.tableView.didAttemptDeleteSystemStatus
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
    }
}

// MARK: Public
extension StatusesViewController {
    static func make() -> StatusesViewController {
        let vc = StatusesViewController()
        vc.navigationItem.title = "Statuses.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: Private
private extension StatusesViewController {
    func action(_ action: StatusesViewModel.Action) {
        switch action {
        case .createStatus:
            let vc = CreateStatusViewController.make()
            present(vc, animated: true)
        case .showToast(let message):
            mainView.makeToast(message)
        }
    }
}
