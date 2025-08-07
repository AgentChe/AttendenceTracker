//
//  CourseViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import RxSwift
import RxCocoa

final class CourseViewModel {
    enum Action {
        case createAttendance(Course)
        case openAttendance(Attendance)
    }
    
    private let course: Driver<Course>
    
    init(course: Course) {
        self.course = BehaviorRelay(value: course).asDriver()
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CourseViewModel {
    struct Input {
        let didTapAddAttendance: Signal<Void>
        let didDelete: Signal<Attendance>
        let didSelect: Signal<Attendance>
    }
    
    struct Output {
        let elements: Driver<[Attendance]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(
                course: course,
                didDelete: input.didDelete
            ),
            action: makeAction(
                didTapAddAttendance: input.didTapAddAttendance,
                didSelect: input.didSelect,
                course: course
            )
        )
    }
}

// MARK: Private
private extension CourseViewModel {
    func makeAction(
        didTapAddAttendance: Signal<Void>,
        didSelect: Signal<Attendance>,
        course: Driver<Course>
    ) -> Driver<Action> {
        let createAttendance = didTapAddAttendance
            .withLatestFrom(course)
            .map { Action.createAttendance($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let openAttendance = didSelect
            .map { Action.openAttendance($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(createAttendance, openAttendance)
    }
    
    func makeElements(course: Driver<Course>, didDelete: Signal<Attendance>) -> Driver<[Attendance]> {
        enum Action {
            case initial([Attendance])
            case created(Attendance)
            case deleted(String)
        }
        
        let initial = course
            .flatMapLatest { [weak self] course -> Driver<[Attendance]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchAttendances(forCourseId: course.id)
                    .asDriver(onErrorJustReturn: [])
            }
        
        return initial
            .withLatestFrom(course) { ($0, $1) }
            .flatMapLatest { initialAttendances, course -> Driver<[Attendance]> in
                let created = AttendanceMediator.shared.didCreatedAttendance
                    .filter { $0.courseId == course.id }
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedAttendanceId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedAction = didDelete
                    .flatMapLatest { [weak self] attendance -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(attendanceId: attendance.id)
                            .map { Action.deleted(attendance.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deletedTrigger, deletedAction)
                    .startWith(.initial(initialAttendances))
                    .scan(initialAttendances) { attendances, action -> [Attendance] in
                        switch action {
                        case .initial(let attendances):
                            return attendances
                        case .created(let attendance):
                            return attendances + [attendance]
                        case .deleted(let attendanceId):
                            var attendances = attendances
                            attendances.removeAll(where: { $0.id == attendanceId })
                            return attendances
                        }
                    }
                    .map { notes -> [Attendance] in
                        notes.sorted(by: { $0.date < $1.date })
                    }
            }
    }
}
