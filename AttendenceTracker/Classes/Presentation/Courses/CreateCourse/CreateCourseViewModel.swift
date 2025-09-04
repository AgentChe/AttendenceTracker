//
//  CreateCourseViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import RxSwift
import RxCocoa

final class CreateCourseViewModel {
    enum Action {
        case createStudent
        case createStatus
        case close
        case openPaygate
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CreateCourseViewModel {
    struct Input {
        let didTapCreateStudent: Signal<Void>
        let didTapCreateStatus: Signal<Void>
        let didChangeSelectedStudent: Signal<(Student, Bool)>
        let didChangeSelectedStatus: Signal<(Status, Bool)>
        let didChangeCourseName: Signal<String>
        let didTapSave: Signal<Void>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[CreateCourseTableElement]>
        let saveEnable: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let students = makeStudents()
        let selectedStudents = makeSelectedStudents(didChangeSelectedStudent: input.didChangeSelectedStudent)
        let statuses = makeStatuses()
        let selectedStatuses = makeSelectedStatuses(didChangeSelectedStatus: input.didChangeSelectedStatus)
        
        return Output(
            action: makeAction(
                didTapCreateStudent: input.didTapCreateStudent,
                didTapCreateStatus: input.didTapCreateStatus,
                didTapSave: input.didTapSave,
                courseName: input.didChangeCourseName,
                selectedStudents: selectedStudents,
                selectedStatuses: selectedStatuses
            ),
            elements: makeElements(
                students: students,
                selectedStudents: selectedStudents,
                statuses: statuses,
                selectedStatuses: selectedStatuses
            ),
            saveEnable: makeSaveEnable(
                courseName: input.didChangeCourseName,
                selectedStudents: selectedStudents,
                selectedStatuses: selectedStatuses
            )
        )
    }
}

// MARK: Private
private extension CreateCourseViewModel {
    func makeAction(
        didTapCreateStudent: Signal<Void>,
        didTapCreateStatus: Signal<Void>,
        didTapSave: Signal<Void>,
        courseName: Signal<String>,
        selectedStudents: Driver<[Student]>,
        selectedStatuses: Driver<[Status]>
    ) -> Driver<Action> {
        let createStudent = didTapCreateStudent
            .map { Action.createStudent }
            .asDriver(onErrorDriveWith: .never())
        
        let createStatus = didTapCreateStatus
            .map { Action.createStatus }
            .asDriver(onErrorDriveWith: .never())
        
        let save = didTapSave
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(courseName)
            .withLatestFrom(selectedStudents) { ($0, $1) }
            .withLatestFrom(selectedStatuses) { ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] courseName, selectedStudents, selectedStatuses -> Driver<Action> in
                guard let self else { return .never() }
                
                func create() -> Driver<Action> {
                    return attendanceManager
                        .createCourse(name: courseName)
                        .flatMap { course -> Single<Void> in
                            Single
                                .zip(
                                    self.attendanceManager
                                        .setEnrollments(studentIds: selectedStudents.map { $0.id }, forCourseId: course.id),
                                    
                                    self.attendanceManager
                                        .setStatuses(ids: selectedStatuses.map { $0.id }, forCourseId: course.id)
                                )
                                .mapToVoid()
                        }
                        .map { Action.close }
                        .asDriver(onErrorDriveWith: .never())
                }
                
                if SessionManager().hasActiveSubscriptions() {
                    return create()
                } else {
                    return attendanceManager
                        .allCoursesCount()
                        .asDriver(onErrorJustReturn: 0)
                        .flatMap { count -> Driver<Action> in
                            if count == 0 {
                                return create()
                            } else {
                                return .just(.openPaygate)
                            }
                        }
                }
            }
        
        return Driver
            .merge(createStudent, createStatus, save)
    }
    
    func makeSaveEnable(
        courseName: Signal<String>,
        selectedStudents: Driver<[Student]>,
        selectedStatuses: Driver<[Status]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(
                courseName.asDriver(onErrorDriveWith: .never()),
                selectedStudents,
                selectedStatuses
            )
            .map { courseName, selectedStudents, selectedStatuses -> Bool in
                let cleanedName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
                return !cleanedName.isEmpty && !selectedStudents.isEmpty && !selectedStatuses.isEmpty
            }
            .startWith(false)
    }
    
    func makeElements(
        students: Driver<[Student]>,
        selectedStudents: Driver<[Student]>,
        statuses: Driver<[Status]>,
        selectedStatuses: Driver<[Status]>
    ) -> Driver<[CreateCourseTableElement]> {
        let studentsElements = students
            .withLatestFrom(selectedStudents) { ($0, $1) }
            .map { students, selectedStudents -> [CreateCourseTableElement] in
                let studentsElements = students.map { student -> CreateCourseTableElement in
                    let studentElement = CreateCourseTableStudentElement(
                        student: student,
                        checked: selectedStudents.contains(where: { $0.id == student.id })
                    )
                    return .student(studentElement)
                }
                
                return [.title(.students)] + studentsElements
            }
        
        let statusesElements = statuses
            .withLatestFrom(selectedStatuses) { ($0, $1) }
            .map { statuses, selectedStatuses -> [CreateCourseTableElement] in
                let statusesElements = statuses.map { status -> CreateCourseTableElement in
                    let statusElement = CreateCourseTableStatusElement(
                        status: status,
                        checked: selectedStatuses.contains(where: { $0.id == status.id })
                    )
                    return .status(statusElement)
                }
                
                return [.title(.statuses)] + statusesElements
            }
        
        return Driver
            .combineLatest(studentsElements, statusesElements)
            .map { $0 + $1 }
    }
    
    func makeSelectedStudents(didChangeSelectedStudent: Signal<(Student, Bool)>) -> Driver<[Student]> {
        didChangeSelectedStudent
            .scan([]) { students, changed -> [Student] in
                var students = students
                
                if changed.1 {
                    students.append(changed.0)
                } else {
                    students.removeAll(where: { $0.id == changed.0.id })
                }
                
                return students
            }
            .startWith([])
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeStudents() -> Driver<[Student]> {
        enum Action {
            case initial([Student])
            case created(Student)
            case deleted(String)
        }
        
        let initial = attendanceManager
            .fetchAllStudents()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialStudents -> Driver<[Student]> in
                let created = AttendanceMediator.shared.didCreatedStudent
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedStudentId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                return Driver
                    .merge(created, deletedTrigger)
                    .startWith(.initial(initialStudents))
                    .scan(initialStudents) { students, action -> [Student] in
                        switch action {
                        case .initial(let students):
                            return students
                        case .created(let student):
                            return students + [student]
                        case .deleted(let studentId):
                            var students = students
                            students.removeAll(where: { $0.id == studentId })
                            return students
                        }
                    }
                    .map { students -> [Student] in
                        students.sorted(by: { $0.firstName < $1.firstName })
                    }
            }
    }
    
    func makeSelectedStatuses(didChangeSelectedStatus: Signal<(Status, Bool)>) -> Driver<[Status]> {
        didChangeSelectedStatus
            .scan([]) { statuses, changed -> [Status] in
                var statuses = statuses
                
                if changed.1 {
                    statuses.append(changed.0)
                } else {
                    statuses.removeAll(where: { $0.id == changed.0.id })
                }
                
                return statuses
            }
            .startWith([])
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeStatuses() -> Driver<[Status]> {
        enum Action {
            case initial([Status])
            case created(Status)
            case deleted(String)
        }
        
        let initial = attendanceManager
            .fetchAllStatuses()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialStatuses -> Driver<[Status]> in
                let created = AttendanceMediator.shared.didCreatedStatus
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedStatusId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                return Driver
                    .merge(created, deletedTrigger)
                    .startWith(.initial(initialStatuses))
                    .scan(initialStatuses) { statuses, action -> [Status] in
                        switch action {
                        case .initial(let statuses):
                            return statuses
                        case .created(let status):
                            return statuses + [status]
                        case .deleted(let statusId):
                            var statuses = statuses
                            statuses.removeAll(where: { $0.id == statusId })
                            return statuses
                        }
                    }
                    .map { statuses -> [Status] in
                        statuses.sorted(by: { $0.title < $1.title })
                    }
            }
    }
}
