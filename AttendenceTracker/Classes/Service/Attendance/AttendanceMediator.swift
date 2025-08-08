//
//  AttendanceMediator.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 03.08.2025.
//

import RxSwift
import RxCocoa

final class AttendanceMediator {
    static let shared = AttendanceMediator()
    
    private lazy var didCreatedStatusTrigger = PublishRelay<Status>()
    private lazy var didDeletedStatusIdTrigger = PublishRelay<String>()
    private lazy var didChangedDefaultStatusTrigger = PublishRelay<Status>()
    
    private lazy var didCreatedCourseTrigger = PublishRelay<Course>()
    private lazy var didDeletedCourseIdTrigger = PublishRelay<String>()
    
    private lazy var didCreatedStudentTrigger = PublishRelay<Student>()
    private lazy var didDeletedStudentIdTrigger = PublishRelay<String>()
    private lazy var didEnrolledStudentsTrigger = PublishRelay<Void>()
    
    private lazy var didCreatedAttendanceTrigger = PublishRelay<Attendance>()
    private lazy var didDeletedAttendanceIdTrigger = PublishRelay<String>()
    
    private lazy var didCreatedAttendanceNoteTrigger = PublishRelay<AttendanceNote>()
    private lazy var didDeletedAttendanceNoteIdTrigger = PublishRelay<String>()
    
    private lazy var didCreatedStudentNoteTrigger = PublishRelay<StudentNote>()
    private lazy var didDeletedStudentNoteIdTrigger = PublishRelay<String>()
    
    private init() {}
}

// MARK: Public
extension AttendanceMediator {
    func created(status: Status) {
        didCreatedStatusTrigger.accept(status)
    }
    
    func deleted(statusId: String) {
        didDeletedStatusIdTrigger.accept(statusId)
    }
    
    func changed(defaultStatus: Status) {
        didChangedDefaultStatusTrigger.accept(defaultStatus)
    }
    
    func created(course: Course) {
        didCreatedCourseTrigger.accept(course)
    }
    
    func deleted(courseId: String) {
        didDeletedCourseIdTrigger.accept(courseId)
    }
    
    func created(student: Student) {
        didCreatedStudentTrigger.accept(student)
    }
    
    func deleted(studentId: String) {
        didDeletedStudentIdTrigger.accept(studentId)
    }
    
    func created(attendance: Attendance) {
        didCreatedAttendanceTrigger.accept(attendance)
    }
    
    func deleted(attendanceId: String) {
        didDeletedAttendanceIdTrigger.accept(attendanceId)
    }
    
    func created(attendanceNote: AttendanceNote) {
        didCreatedAttendanceNoteTrigger.accept(attendanceNote)
    }
    
    func deleted(attendanceNoteId: String) {
        didDeletedAttendanceNoteIdTrigger.accept(attendanceNoteId)
    }
    
    func created(studentNote: StudentNote) {
        didCreatedStudentNoteTrigger.accept(studentNote)
    }
    
    func deleted(studentNoteId: String) {
        didDeletedStudentNoteIdTrigger.accept(studentNoteId)
    }
    
    func enrolledStudents() {
        didEnrolledStudentsTrigger.accept(Void())
    }
    
    var didCreatedStatus: Signal<Status> {
        didCreatedStatusTrigger.asSignal()
    }
    
    var didDeletedStatusId: Signal<String> {
        didDeletedStatusIdTrigger.asSignal()
    }
    
    var didChangedDefaultStatus: Signal<Status> {
        didChangedDefaultStatusTrigger.asSignal()
    }
    
    var didCreatedCourse: Signal<Course> {
        didCreatedCourseTrigger.asSignal()
    }
    
    var didDeletedCourseId: Signal<String> {
        didDeletedCourseIdTrigger.asSignal()
    }
    
    var didCreatedStudent: Signal<Student> {
        didCreatedStudentTrigger.asSignal()
    }
    
    var didDeletedStudentId: Signal<String> {
        didDeletedStudentIdTrigger.asSignal()
    }
    
    var didCreatedAttendance: Signal<Attendance> {
        didCreatedAttendanceTrigger.asSignal()
    }
    
    var didDeletedAttendanceId: Signal<String> {
        didDeletedAttendanceIdTrigger.asSignal()
    }
    
    var didCreatedAttendanceNote: Signal<AttendanceNote> {
        didCreatedAttendanceNoteTrigger.asSignal()
    }
    
    var didDeletedAttendanceNoteId: Signal<String> {
        didDeletedAttendanceNoteIdTrigger.asSignal()
    }
    
    var didCreatedStudentNote: Signal<StudentNote> {
        didCreatedStudentNoteTrigger.asSignal()
    }
    
    var didDeletedStudentNoteId: Signal<String> {
        didDeletedStudentNoteIdTrigger.asSignal()
    }
    
    var didEnrolledStudents: Signal<Void> {
        didEnrolledStudentsTrigger.asSignal()
    }
}
