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
        case selectNewStatus([Status], String)
        case emailReport((AttendanceNote))
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
        let didTapChangeStatus: Signal<AttendanceTableRecordElement>
        let didSelectNewStatus: Signal<(Status, String)>
        let didTapEmailReport: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[AttendanceTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let students = makeStudents(attendance: attendance)
        let statuses = makeStatuses(attendance: attendance)
        let records = makeRecords(attendance: attendance)
        let recordsElements = makeRecordsElements(
            students: students,
            statuses: statuses,
            records: records,
            didSelectNewStatus: input.didSelectNewStatus
        )
        let notes = makeNotes(
            attendance: attendance,
            didDelete: input.didDeleteNote
        )
        
        return Output(
            elements: makeElements(
                recordsElements: recordsElements,
                notes: notes
            ),
            action: makeAction(
                attendance: attendance,
                didSelectNote: input.didSelectNote,
                didTapAddNote: input.didTapAddNote,
                didTapChangeStatus: input.didTapChangeStatus,
                statuses: statuses
            )
        )
    }
}

// MARK: Private
private extension AttendanceViewModel {
    func makeAction(
        attendance: Driver<Attendance>,
        didSelectNote: Signal<AttendanceNote>,
        didTapAddNote: Signal<Void>,
        didTapChangeStatus: Signal<AttendanceTableRecordElement>,
        statuses: Driver<[Status]>
    ) -> Driver<Action> {
        let createNote = didTapAddNote
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(attendance)
            .map { Action.createNote($0) }
        
        let openNote = didSelectNote
            .map { Action.openNote($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let selectNewStatus = didTapChangeStatus
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(statuses) { ($0.recordId, $1) }
            .map { Action.selectNewStatus($1, $0) }
            
        return Driver
            .merge(createNote, openNote, selectNewStatus)
    }
    
    func makeElements(
        recordsElements: Driver<[AttendanceTableRecordElement]>,
        notes: Driver<[AttendanceNote]>
    ) -> Driver<[AttendanceTableElement]> {
        Driver
            .combineLatest(recordsElements, notes)
            .map { recordsElements, notes -> [AttendanceTableElement] in
                [.recordsTitle] + recordsElements.map { .record($0) } + [.notesTitle] + notes.map { .note($0) }
            }
    }
    
    func makeRecordsElements(
        students: Driver<[Student]>,
        statuses: Driver<[Status]>,
        records: Driver<[AttendanceRecord]>,
        didSelectNewStatus: Signal<(Status, String)>
    ) -> Driver<[AttendanceTableRecordElement]> {
        enum Action {
            case initial([AttendanceTableRecordElement])
            case selectedNewStatus((Status, String))
        }
        
        let recordsElements = Driver
            .combineLatest(students, statuses, records)
            .map { students, statuses, records -> [AttendanceTableRecordElement] in
                records.compactMap { record -> AttendanceTableRecordElement? in
                    guard
                        let student = students.first(where: { $0.id == record.studentId }),
                        let status = statuses.first(where: { $0.id == record.statusId })
                    else { return nil }
                    
                    return AttendanceTableRecordElement(
                        recordId: record.id,
                        student: student,
                        status: status
                    )
                }
            }
        
        return recordsElements
            .flatMapLatest { [weak self] initialElements -> Driver<[AttendanceTableRecordElement]> in
                guard let self else { return .never() }
                
                let selectedNewStatus = didSelectNewStatus
                    .flatMap { status, recordId -> Driver<Action> in
                        self.attendanceManager
                            .update(attendanceRecordId: recordId, newStatusId: status.id)
                            .map { _ in Action.selectedNewStatus((status, recordId)) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                    .asDriver(onErrorDriveWith: .never())
                
                return selectedNewStatus
                    .startWith(.initial(initialElements))
                    .scan(initialElements) { elements, action -> [AttendanceTableRecordElement] in
                        switch action {
                        case .initial(let elements):
                            return elements
                        case .selectedNewStatus((let status, let recordId)):
                            var elements = elements
                            
                            if let index = elements.firstIndex(where: { $0.recordId == recordId }) {
                                let currentElement = elements[index]
                                
                                let newElement = AttendanceTableRecordElement(
                                    recordId: currentElement.recordId,
                                    student: currentElement.student,
                                    status: status
                                )
                                
                                elements[index] = newElement
                            }
                            
                            return elements
                        }
                    }
            }
    }
    
    func makeRecords(attendance: Driver<Attendance>) -> Driver<[AttendanceRecord]> {
        attendance
            .flatMapLatest { [weak self] attendance -> Driver<[AttendanceRecord]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchAttendanceRecords(forAttendanceId: attendance.id)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeStudents(attendance: Driver<Attendance>) -> Driver<[Student]> {
        attendance
            .flatMapLatest { [weak self] attendance -> Driver<[Student]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchStudents(forCourseId: attendance.courseId)
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeStatuses(attendance: Driver<Attendance>) -> Driver<[Status]> {
        attendance
            .flatMapLatest { [weak self] attendance -> Driver<[Status]> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .fetchStatuses(forCourseId: attendance.courseId)
                    .asDriver(onErrorJustReturn: [])
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
