//
//  AttendanceViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import RxSwift
import RxCocoa

final class AttendanceViewModel {
    enum Action {
        case createNote(Attendance)
        case openNote(AttendanceNote)
    }
    
    private let attendance: Driver<Attendance>
    
    init(attendance: Attendance) {
        self.attendance = BehaviorRelay(value: attendance).asDriver()
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension AttendanceViewModel {
    struct Input {
        let didDeleteNote: Signal<AttendanceNote>
        let didSelectNote: Signal<AttendanceNote>
        let didTapAddNote: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[AttendanceTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let notes = makeNotes(
            attendance: attendance,
            didDelete: input.didDeleteNote
        )
        
        return Output(
            elements: makeElements(notes: notes),
            action: makeAction(
                attendance: attendance,
                didSelectNote: input.didSelectNote,
                didTapAddNote: input.didTapAddNote
            )
        )
    }
}

// MARK: Private
private extension AttendanceViewModel {
    func makeAction(
        attendance: Driver<Attendance>,
        didSelectNote: Signal<AttendanceNote>,
        didTapAddNote: Signal<Void>
    ) -> Driver<Action> {
        let createNote = didTapAddNote
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(attendance)
            .map { Action.createNote($0) }
        
        let openNote = didSelectNote
            .map { Action.openNote($0) }
            .asDriver(onErrorDriveWith: .never())
            
        return Driver
            .merge(createNote, openNote)
    }
    
    func makeElements(notes: Driver<[AttendanceNote]>) -> Driver<[AttendanceTableElement]> {
        notes
            .map { notes -> [AttendanceTableElement] in
                [.notesTitle] + notes.map { .note($0) }
            }
    }
    
    func makeNotes(attendance: Driver<Attendance>, didDelete: Signal<AttendanceNote>) -> Driver<[AttendanceNote]> {
        enum Action {
            case initial([AttendanceNote])
            case created(AttendanceNote)
            case deleted(String)
        }
        
        let initial = attendance
            .flatMapLatest { [weak self] attendance -> Driver<[AttendanceNote]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchAttendanceNotes(forAttendanceId: attendance.id)
                    .asDriver(onErrorJustReturn: [])
            }
        
        return initial
            .withLatestFrom(attendance) { ($0, $1) }
            .flatMapLatest { initialNotes, attendance -> Driver<[AttendanceNote]> in
                let created = AttendanceMediator.shared.didCreatedAttendanceNote
                    .filter { $0.attendanceId == attendance.id }
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedTrigger = AttendanceMediator.shared.didDeletedAttendanceId
                    .map { Action.deleted($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deletedAction = didDelete
                    .flatMapLatest { [weak self] attendanceNote -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(attendanceNoteId: attendanceNote.id)
                            .map { Action.deleted(attendanceNote.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deletedTrigger, deletedAction)
                    .startWith(.initial(initialNotes))
                    .scan(initialNotes) { notes, action -> [AttendanceNote] in
                        switch action {
                        case .initial(let attendanceNotes):
                            return attendanceNotes
                        case .created(let attendanceNote):
                            return notes + [attendanceNote]
                        case .deleted(let attendanceNoteId):
                            var notes = notes
                            notes.removeAll(where: { $0.id == attendanceNoteId })
                            return notes
                        }
                    }
                    .map { notes -> [AttendanceNote] in
                        notes.sorted(by: { $0.createdAt > $1.createdAt })
                    }
            }
    }
}
