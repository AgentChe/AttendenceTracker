//
//  StudentsViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import RxSwift
import RxCocoa

final class StudentsViewModel {
    enum Action {
        case createStudent
        case openStudent(Student)
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension StudentsViewModel {
    struct Input {
        let didTapCreateStudent: Signal<Void>
        let didSelect: Signal<Student>
        let didDelete: Signal<Student>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[Student]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                didTapCreateStudent: input.didTapCreateStudent,
                didSelect: input.didSelect
            ),
            elements: makeElements(didDelete: input.didDelete)
        )
    }
}

// MARK: Private
private extension StudentsViewModel {
    func makeAction(
        didTapCreateStudent: Signal<Void>,
        didSelect: Signal<Student>
    ) -> Driver<Action> {
        let createStudent = didTapCreateStudent
            .map { Action.createStudent }
            .asDriver(onErrorDriveWith: .never())
        
        let openStudent = didSelect
            .map { Action.openStudent($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(createStudent, openStudent)
    }
    
    func makeElements(didDelete: Signal<Student>) -> Driver<[Student]> {
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
                
                let deletedAction = didDelete
                    .flatMapLatest { [weak self] student -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(studentId: student.id)
                            .map { Action.deleted(student.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deletedTrigger, deletedAction)
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
}
