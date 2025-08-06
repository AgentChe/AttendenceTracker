//
//  CoursesViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import RxSwift
import RxCocoa

final class CoursesViewModel {
    enum Action {
        case createCourse
        case openCourse(Course)
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CoursesViewModel {
    struct Input {
        let didTapAddCourse: Signal<Void>
        let didDelete: Signal<Course>
        let didSelect: Signal<Course>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[Course]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapAddCourse: input.didTapAddCourse,
                didSelect: input.didSelect
            ),
            elements: makeElements(didDelete: input.didDelete)
        )
    }
}

// MARK: Private
private extension CoursesViewModel {
    func makeAction(
        didTapAddCourse: Signal<Void>,
        didSelect: Signal<Course>
    ) -> Driver<Action> {
        let createCourse = didTapAddCourse
            .map { Action.createCourse }
            .asDriver(onErrorDriveWith: .never())
        
        let openCourse = didSelect
            .map { Action.openCourse($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(createCourse, openCourse)
    }
    
    func makeElements(didDelete: Signal<Course>) -> Driver<[Course]> {
        enum Action {
            case initial([Course])
            case created(Course)
            case deleted(String)
        }
        
        let initial = attendanceManager
            .fetchAllCourses()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialCourses -> Driver<[Course]> in
                let created = AttendanceMediator.shared.didCreatedCourse
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedCourseId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedAction = didDelete
                    .flatMapLatest { [weak self] course -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(courseId: course.id)
                            .map { Action.deleted(course.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deletedTrigger, deletedAction)
                    .startWith(.initial(initialCourses))
                    .scan(initialCourses) { courses, action -> [Course] in
                        switch action {
                        case .initial(let courses):
                            return courses
                        case .created(let course):
                            return courses + [course]
                        case .deleted(let courseId):
                            var courses = courses
                            courses.removeAll(where: { $0.id == courseId })
                            return courses
                        }
                    }
                    .map { notes -> [Course] in
                        notes.sorted(by: { $0.name < $1.name })
                    }
            }
    }
}
