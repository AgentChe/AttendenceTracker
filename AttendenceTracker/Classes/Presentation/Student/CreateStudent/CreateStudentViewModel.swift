//
//  CreateStudentViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import RxSwift
import RxCocoa

final class CreateStudentViewModel {
    enum Action {
        case close
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CreateStudentViewModel {
    struct Input {
        let didCreate: Signal<CreateStudentView.Data>
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
private extension CreateStudentViewModel {
    func makeAction(didCreate: Signal<CreateStudentView.Data>) -> Driver<Action> {
        didCreate
            .flatMapLatest { [weak self] data -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createStudent(
                        firstName: data.firstName,
                        lastName: data.lastName,
                        email: data.email
                    )
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
