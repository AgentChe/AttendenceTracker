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
        case close
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension CreateCourseViewModel {
    struct Input {
        let didTapCreateStudent: Signal<Void>
        let didChangeSelectedStudent: Signal<(Student, Bool)>
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
        
        return Output(
            action: makeAction(
                didTapCreateStudent: input.didTapCreateStudent,
                didTapSave: input.didTapSave,
                courseName: input.didChangeCourseName,
                selectedStudents: selectedStudents
            ),
            elements: makeElements(
                students: students,
                selectedStudents: selectedStudents
            ),
            saveEnable: makeSaveEnable(
                courseName: input.didChangeCourseName,
                selectedStudents: selectedStudents
            )
        )
    }
}

// MARK: Private
private extension CreateCourseViewModel {
    func makeAction(
        didTapCreateStudent: Signal<Void>,
        didTapSave: Signal<Void>,
        courseName: Signal<String>,
        selectedStudents: Driver<[Student]>
    ) -> Driver<Action> {
        let createStudent = didTapCreateStudent
            .map { Action.createStudent }
            .asDriver(onErrorDriveWith: .never())
        
        let save = didTapSave
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(courseName)
            .withLatestFrom(selectedStudents) { ($0, $1) }
            .flatMapLatest { [weak self] courseName, selectedStudents -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createCourse(name: courseName)
                    .flatMap { course -> Single<Void> in
                        self.attendanceManager
                            .setEnrollments(studentIds: selectedStudents.map { $0.id }, forCourseId: course.id)
                    }
                    .map { Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return Driver
            .merge(createStudent, save)
    }
    
    func makeSaveEnable(
        courseName: Signal<String>,
        selectedStudents: Driver<[Student]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(courseName.asDriver(onErrorDriveWith: .never()), selectedStudents)
            .map { courseName, selectedStudents -> Bool in
                let cleanedName = courseName.trimmingCharacters(in: .whitespacesAndNewlines)
                return !cleanedName.isEmpty && !selectedStudents.isEmpty
            }
            .startWith(false)
    }
    
    func makeElements(
        students: Driver<[Student]>,
        selectedStudents: Driver<[Student]>
    ) -> Driver<[CreateCourseTableElement]> {
        students
            .withLatestFrom(selectedStudents) { ($0, $1) }
            .map { students, selectedStudents -> [CreateCourseTableElement] in
                let studentsElements = students.map { student -> CreateCourseTableElement in
                    let studentElement = CreateCourseTableStudentElement(
                        student: student,
                        checked: selectedStudents.contains(where: { $0.id == student.id })
                    )
                    return .student(studentElement)
                }
                
                return [.title] + studentsElements
            }
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
}
