//
//  CreateAttendanceNoteViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import RxSwift
import RxCocoa

final class CreateAttendanceNoteViewModel {
    enum Action {
        case close
    }
    
    private let attendance: Driver<Attendance>
    
    private lazy var attendanceManager = AttendanceManager()
    
    init(attendance: Attendance) {
        self.attendance = BehaviorRelay(value: attendance).asDriver()
    }
}

// MARK: Public
extension CreateAttendanceNoteViewModel {
    struct Input {
        let didCreate: Signal<String>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                attendance: attendance,
                didCreate: input.didCreate
            )
        )
    }
}

// MARK: Private
private extension CreateAttendanceNoteViewModel {
    func makeAction(attendance: Driver<Attendance>, didCreate: Signal<String>) -> Driver<Action> {
        didCreate
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(attendance) { ($0, $1) }
            .flatMapLatest { [weak self] text, attendance -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createAttendanceNote(
                        attendanceId: attendance.id,
                        text: text
                    )
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
