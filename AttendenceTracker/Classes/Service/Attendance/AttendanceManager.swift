//
//  AttendanceManager.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import RxSwift

protocol AttendanceManagerProtocol {
    func obtainStatuses() -> Single<[Status]>
    func createStatus(name: String, color: Color) -> Single<Status>
    func setup(defaultStatus: Status) -> Single<Void>
    func defaultStatus() -> Single<Status>
    func delete(statusId: String) -> Single<Void>
    
    func obtainStudents() -> Single<[Student]>
    func createStudent(
        firstName: String,
        lastName: String,
        email: String
    ) -> Single<Student>
    func delete(studentId: String) -> Single<Void>
    
    func obtainCourses() -> Single<[Course]>
    func createCourse(name: String, students: [String]) -> Single<Course>
    func delete(courseId: String) -> Single<Void>
    
    func obtainAttendances(courseId: String) -> Single<[Attendance]>
    func createAttendance(
        courseId: String,
        date: TimeInterval,
        records: [Attendance.Record]
    ) -> Single<Attendance>
    func update(attendance: Attendance) -> Single<Attendance>
    func delete(attendanceId: String) -> Single<Void>
    
    func obtainAttendanceNotes(attendanceId: String) -> Single<[AttendanceNote]>
    func createAttendanceNote(attendanceId: String, text: String) -> Single<AttendanceNote>
    func update(attendanceNote: AttendanceNote) -> Single<AttendanceNote>
    func delete(attendanceNoteId: String) -> Single<Void>
    
    func obtainStudentsNotes(studentId: String) -> Single<[StudentNote]>
    func createStudentNote(studentId: String, text: String) -> Single<StudentNote>
    func update(studentNote: StudentNote) -> Single<StudentNote>
    func delete(studentNoteId: String) -> Single<Void>
    
}

final class AttendanceManager {}
