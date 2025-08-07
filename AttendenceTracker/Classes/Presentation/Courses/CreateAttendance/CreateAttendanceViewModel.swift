//
//  CreateAttendanceViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import RxSwift
import RxCocoa

final class CreateAttendanceViewModel {
    enum Action {
        case close
    }
    
    private let course: Driver<Course>
    
    private lazy var attendanceManager = AttendanceManager()
    
    init(course: Course) {
        self.course = BehaviorRelay(value: course).asDriver()
    }
}

// MARK: Public
extension CreateAttendanceViewModel {
    struct Input {
        let didCreate: Signal<Date>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                course: course,
                didCreate: input.didCreate
            )
        )
    }
}

// MARK: Private
private extension CreateAttendanceViewModel {
    func makeAction(course: Driver<Course>, didCreate: Signal<Date>) -> Driver<Action> {
        didCreate
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(course) { ($0, $1) }
            .flatMapLatest { [weak self] date, course -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createAttendance(courseId: course.id, date: date.timeIntervalSince1970)
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
