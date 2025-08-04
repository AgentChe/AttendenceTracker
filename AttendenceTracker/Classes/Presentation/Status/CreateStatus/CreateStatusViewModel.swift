//
//  CreateStatusViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import RxSwift
import RxCocoa

final class CreateStatusViewModel {
    enum Action {
        case close
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CreateStatusViewModel {
    struct Input {
        let didCreate: Signal<String>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(didCreate: input.didCreate)
        )
    }
}

// MARK: Private
private extension CreateStatusViewModel {
    func makeAction(didCreate: Signal<String>) -> Driver<Action> {
        didCreate
            .flatMapLatest { [weak self] name -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createStatus(name: name)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
