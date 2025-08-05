//
//  StudentNotesViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import RxSwift
import RxCocoa

final class StudentNotesViewModel {
    enum Action {
        case createNote(Student)
        case openNote(StudentNote)
        case emailReport(Student, [StudentNote])
    }
    
    private let student: Driver<Student>
    
    private lazy var attendanceManager = AttendanceManager()
    
    init(student: Student) {
        self.student = BehaviorRelay(value: student).asDriver()
    }
}

// MARK: Public
extension StudentNotesViewModel {
    struct Input {
        let didTapAddNote: Signal<Void>
        let didDelete: Signal<StudentNote>
        let didTapEmailReport: Signal<Void>
        let didSelect: Signal<StudentNote>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[StudentNote]>
    }
    
    func configure(input: Input) -> Output {
        let notes = makeElements(
            student: student,
            didDelete: input.didDelete
        )
        
        return Output(
            action: makeAction(
                student: student,
                didTapAddNote: input.didTapAddNote,
                didSelect: input.didSelect,
                didTapEmailReport: input.didTapEmailReport,
                notes: notes
            ),
            elements: notes
        )
    }
}

// MARK: Private
private extension StudentNotesViewModel {
    func makeAction(
        student: Driver<Student>,
        didTapAddNote: Signal<Void>,
        didSelect: Signal<StudentNote>,
        didTapEmailReport: Signal<Void>,
        notes: Driver<[StudentNote]>
    ) -> Driver<Action> {
        let createNote = didTapAddNote
            .withLatestFrom(student)
            .map { Action.createNote($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let openNote = didSelect
            .map { Action.openNote($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let emailReport = didTapEmailReport
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(student)
            .withLatestFrom(notes) { ($0, $1) }
            .map { Action.emailReport($0, $1) }
        
        return Driver
            .merge(createNote, openNote, emailReport)
    }
    
    func makeElements(student: Driver<Student>, didDelete: Signal<StudentNote>) -> Driver<[StudentNote]> {
        enum Action {
            case initial([StudentNote])
            case created(StudentNote)
            case deleted(String)
        }
        
        let initial = student
            .flatMapLatest { [weak self] student -> Driver<[StudentNote]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchStudentNotes(forStudentId: student.id)
                    .asDriver(onErrorJustReturn: [])
            }
        
        return initial
            .withLatestFrom(student) { ($0, $1) }
            .flatMapLatest { initialNotes, student -> Driver<[StudentNote]> in
                let created = AttendanceMediator.shared.didCreatedStudentNote
                    .filter { $0.studentId == student.id }
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedStudentId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedAction = didDelete
                    .flatMapLatest { [weak self] studentNote -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(studentNoteId: studentNote.id)
                            .map { Action.deleted(studentNote.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deletedTrigger, deletedAction)
                    .startWith(.initial(initialNotes))
                    .scan(initialNotes) { notes, action -> [StudentNote] in
                        switch action {
                        case .initial(let studentNotes):
                            return studentNotes
                        case .created(let studentNote):
                            return notes + [studentNote]
                        case .deleted(let studentNoteId):
                            var notes = notes
                            notes.removeAll(where: { $0.id == studentNoteId })
                            return notes
                        }
                    }
                    .map { notes -> [StudentNote] in
                        notes.sorted(by: { $0.createdAt > $1.createdAt })
                    }
            }
    }
}
