//
//  AttendanceManager.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import RxSwift
import GRDB

protocol AttendanceManagerProtocol {
    func fetchAllStatuses() -> Single<[Status]>
    func createStatus(name: String, color: Color) -> Single<Status>
    func delete(statusId: String) -> Single<Void>
    func setup(defaultStatus: Status) -> Single<Void>
    func defaultStatus() -> Single<Status>
    
    func createCourse(name: String) -> Single<Course>
    func delete(courseId: String) -> Single<Void>
    func fetchAllCourses() -> Single<[Course]>
    func fetchStatuses(forCourseId courseId: String) -> Single<[Status]>
    func setStatuses(ids: [String], forCourseId courseId: String) -> Single<Void>

    func createStudent(
        firstName: String,
        lastName: String,
        email: String
    ) -> Single<Student>
    func delete(studentId: String) -> Single<Void>
    func fetchAllStudents() -> Single<[Student]>
    func fetchStudents(forCourseId courseId: String) -> Single<[Student]>
    func setEnrollments(studentIds: [String], forCourseId courseId: String) -> Single<Void>

    func createAttendance(courseId: String, date: TimeInterval) -> Single<Attendance>
    func delete(attendanceId: String) -> Single<Void>
    func fetchAttendances(forCourseId courseId: String) -> Single<[Attendance]>

    func createAttendanceRecord(
        attendanceId: String,
        studentId: String,
        statusId: String
    ) -> Single<AttendanceRecord>
    func delete(attendanceRecordId: String) -> Single<Void>
    func fetchAttendanceRecords(forAttendanceId attendanceId: String) -> Single<[AttendanceRecord]>

    func createAttendanceNote(attendanceId: String, text: String) -> Single<AttendanceNote>
    func delete(attendanceNoteId: String) -> Single<Void>
    func fetchAttendanceNotes(forAttendanceId attendanceId: String) -> Single<[AttendanceNote]>

    func createStudentNote(studentId: String, text: String) -> Single<StudentNote>
    func delete(studentNoteId: String) -> Single<Void> 
    func fetchStudentNotes(forStudentId studentId: String) -> Single<[StudentNote]>
}

final class AttendanceManager {
    private let dbQueue: DatabaseQueue
    
    init() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("attendance.sqlite")
        do {
            dbQueue = try DatabaseQueue(path: fileURL.path)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Error initializing database: \(error)")
        }
    }
}

extension AttendanceManager: AttendanceManagerProtocol {
    func fetchAllStatuses() -> Single<[Status]> {
        Single.create { single in
            do {
                let statuses = try self.dbQueue.read { db in
                    try Status.fetchAll(db)
                }
                single(.success(statuses))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createStatus(name: String, color: Color) -> Single<Status> {
        Single.create { single in
            let status = Status(
                id: UUID().uuidString,
                title: name,
                color: color,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try status.insert(db)
                }
                single(.success(status))
                
                AttendanceMediator.shared.created(status: status)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(statusId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try Status.deleteOne(db, key: statusId)
                    
                    try CourseStatus.filter(Column("statusId") == statusId).deleteAll(db)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(statusId: statusId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func setup(defaultStatus: Status) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try db.create(table: "default_status", ifNotExists: true) { t in
                        t.column("statusId", .text).primaryKey()
                    }
                    
                    try db.execute(sql: "DELETE FROM default_status")
                    try db.execute(sql: "INSERT INTO default_status (statusId) VALUES (?)", arguments: [defaultStatus.id])
                }
                single(.success(()))
                
                AttendanceMediator.shared.changed(defaultStatus: defaultStatus)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func defaultStatus() -> Single<Status> {
        Single.create { single in
            do {
                let status = try self.dbQueue.read { db -> Status in
                    guard let row = try Row.fetchOne(db, sql: "SELECT statusId FROM default_status"),
                          let defId: String = row["statusId"] else {
                        throw NSError(domain: "AttendanceManager", code: 0,
                                      userInfo: [NSLocalizedDescriptionKey: "Default status not set"])
                    }
                    guard let status = try Status.fetchOne(db, key: defId) else {
                        throw NSError(domain: "AttendanceManager", code: 0,
                                      userInfo: [NSLocalizedDescriptionKey: "Default status not found"])
                    }
                    return status
                }
                single(.success(status))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createCourse(name: String) -> Single<Course> {
        Single.create { single in
            let course = Course(
                id: UUID().uuidString,
                name: name,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try course.insert(db)
                }
                single(.success(course))
                
                AttendanceMediator.shared.created(course: course)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(courseId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try CourseStatus.filter(Column("courseId") == courseId).deleteAll(db)
                    try Enrollment.filter(Column("courseID") == courseId).deleteAll(db)

                    let attendanceIds = try Row.fetchAll(db,
                        sql: "SELECT id FROM Attendance WHERE courseId = ?", arguments: [courseId]
                    ).compactMap { $0["id"] as? String }
                    if !attendanceIds.isEmpty {
                        let idsList = attendanceIds.map { "'\($0)'" }.joined(separator: ",")
                        try db.execute(sql: "DELETE FROM AttendanceRecord WHERE attendanceId IN (\(idsList))")
                        try db.execute(sql: "DELETE FROM AttendanceNote WHERE attendanceId IN (\(idsList))")
                    }
                    try Attendance.filter(Column("courseId") == courseId).deleteAll(db)

                    try Course.deleteOne(db, key: courseId)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(courseId: courseId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchAllCourses() -> Single<[Course]> {
        Single.create { single in
            do {
                let courses = try self.dbQueue.read { db in
                    try Course.fetchAll(db)
                }
                single(.success(courses))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchStatuses(forCourseId courseId: String) -> Single<[Status]> {
        Single.create { single in
            do {
                let statuses = try self.dbQueue.read { db in
                    try Status.fetchAll(db,
                        sql: """
                        SELECT Status.* FROM Status
                        JOIN CourseStatus ON Status.id = CourseStatus.statusId
                        WHERE CourseStatus.courseId = ?
                        """, arguments: [courseId]
                    )
                }
                single(.success(statuses))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func setStatuses(ids: [String], forCourseId courseId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try CourseStatus.filter(Column("courseId") == courseId).deleteAll(db)
                    for statusId in ids {
                        let mapping = CourseStatus(
                            id: UUID().uuidString,
                            courseId: courseId,
                            statusId: statusId
                        )
                        try mapping.insert(db)
                    }
                }
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createStudent(
        firstName: String,
        lastName: String,
        email: String
    ) -> Single<Student> {
        Single.create { single in
            let student = Student(
                id: UUID().uuidString,
                firstName: firstName,
                lastName: lastName,
                email: email,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try student.insert(db)
                }
                single(.success(student))
                
                AttendanceMediator.shared.created(student: student)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(studentId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try StudentNote.filter(Column("studentId") == studentId).deleteAll(db)
                    try Enrollment.filter(Column("studentID") == studentId).deleteAll(db)
                    try AttendanceRecord.filter(Column("studentId") == studentId).deleteAll(db)
                    try Student.deleteOne(db, key: studentId)
                }
                
                single(.success(()))
                
                AttendanceMediator.shared.deleted(studentId: studentId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchAllStudents() -> Single<[Student]> {
        Single.create { single in
            do {
                let students = try self.dbQueue.read { db in
                    try Student.fetchAll(db)
                }
                single(.success(students))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchStudents(forCourseId courseId: String) -> Single<[Student]> {
        Single.create { single in
            do {
                let students = try self.dbQueue.read { db in
                    try Student.fetchAll(db,
                        sql: """
                        SELECT Student.* FROM Student
                        JOIN Enrollment ON Student.id = Enrollment.studentID
                        WHERE Enrollment.courseID = ?
                        """, arguments: [courseId]
                    )
                }
                single(.success(students))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func setEnrollments(studentIds: [String], forCourseId courseId: String) -> Single<Void> {
        Single.create { single in
            let newEnrollments = studentIds.map { studentId in
                Enrollment(
                    id: UUID().uuidString,
                    courseID: courseId,
                    studentID: studentId
                )
            }

            do {
                try self.dbQueue.write { db in
                    try Enrollment
                        .filter(Column("courseID") == courseId)
                        .deleteAll(db)

                    for enrollment in newEnrollments {
                        try enrollment.insert(db)
                    }
                }
                
                single(.success(()))
                
                AttendanceMediator.shared.enrolledStudents()
            }
            catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    func createAttendance(courseId: String, date: TimeInterval) -> Single<Attendance> {
        Single.create { single in
            let attendance = Attendance(
                id: UUID().uuidString,
                courseId: courseId,
                date: date,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try attendance.insert(db)
                }
                single(.success(attendance))
                
                AttendanceMediator.shared.created(attendance: attendance)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(attendanceId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try AttendanceRecord.filter(Column("attendanceId") == attendanceId).deleteAll(db)
                    try AttendanceNote.filter(Column("attendanceId") == attendanceId).deleteAll(db)
                    try Attendance.deleteOne(db, key: attendanceId)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(attendanceId: attendanceId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchAttendances(forCourseId courseId: String) -> Single<[Attendance]> {
        Single.create { single in
            do {
                let attendances = try self.dbQueue.read { db in
                    try Attendance.fetchAll(db, sql: "SELECT * FROM Attendance WHERE courseId = ?", arguments: [courseId])
                }
                single(.success(attendances))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createAttendanceRecord(
        attendanceId: String,
        studentId: String,
        statusId: String
    ) -> Single<AttendanceRecord> {
        Single.create { single in
            let record = AttendanceRecord(
                id: UUID().uuidString,
                attendanceId: attendanceId,
                studentId: studentId,
                statusId: statusId
            )
            do {
                try self.dbQueue.write { db in
                    try record.insert(db)
                }
                single(.success(record))
                
                AttendanceMediator.shared.created(attendanceRecord: record)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(attendanceRecordId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try AttendanceRecord.deleteOne(db, key: attendanceRecordId)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(attendanceRecordId: attendanceRecordId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchAttendanceRecords(forAttendanceId attendanceId: String) -> Single<[AttendanceRecord]> {
        Single.create { single in
            do {
                let records = try self.dbQueue.read { db in
                    try AttendanceRecord.fetchAll(db, sql: "SELECT * FROM AttendanceRecord WHERE attendanceId = ?", arguments: [attendanceId])
                }
                single(.success(records))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createAttendanceNote(attendanceId: String, text: String) -> Single<AttendanceNote> {
        Single.create { single in
            let note = AttendanceNote(
                id: UUID().uuidString,
                attendanceId: attendanceId,
                text: text,
                createdAt: Date().timeIntervalSince1970
            )
            do {
                try self.dbQueue.write { db in
                    try note.insert(db)
                }
                single(.success(note))
                
                AttendanceMediator.shared.created(attendanceNote: note)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func delete(attendanceNoteId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try AttendanceNote.deleteOne(db, key: attendanceNoteId)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(attendanceNoteId: attendanceNoteId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchAttendanceNotes(forAttendanceId attendanceId: String) -> Single<[AttendanceNote]> {
        Single.create { single in
            do {
                let notes = try self.dbQueue.read { db in
                    try AttendanceNote.fetchAll(db, sql: "SELECT * FROM AttendanceNote WHERE attendanceId = ?", arguments: [attendanceId])
                }
                single(.success(notes))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func createStudentNote(studentId: String, text: String) -> Single<StudentNote> {
        Single.create { single in
            let note = StudentNote(
                id: UUID().uuidString,
                studentId: studentId,
                text: text,
                createdAt: Date().timeIntervalSince1970
            )
            
            do {
                try self.dbQueue.write { db in
                    try note.insert(db)
                }
                single(.success(note))
                
                AttendanceMediator.shared.created(studentNote: note)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func delete(studentNoteId: String) -> Single<Void> {
        Single.create { single in
            do {
                try self.dbQueue.write { db in
                    try StudentNote.deleteOne(db, key: studentNoteId)
                }
                single(.success(()))
                
                AttendanceMediator.shared.deleted(studentNoteId: studentNoteId)
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func fetchStudentNotes(forStudentId studentId: String) -> Single<[StudentNote]> {
        Single.create { single in
            do {
                let notes = try self.dbQueue.read { db in
                    try StudentNote.fetchAll(db, sql: "SELECT * FROM StudentNote WHERE studentId = ?", arguments: [studentId])
                }
                single(.success(notes))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

// MARK: Private
private extension AttendanceManager {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createTables") { db in
            try db.create(table: "Status") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("color", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(table: "default_status") { t in
                t.column("statusId", .text).primaryKey().notNull()
            }
            try db.create(table: "Course") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(table: "CourseStatus") { t in
                t.column("id", .text).primaryKey()
                t.column("courseId", .text).notNull().indexed().references("Course", onDelete: .cascade)
                t.column("statusId", .text).notNull().indexed().references("Status", onDelete: .cascade)
            }
            try db.create(table: "Student") { t in
                t.column("id", .text).primaryKey()
                t.column("firstName", .text).notNull()
                t.column("lastName", .text).notNull()
                t.column("email", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(table: "Enrollment") { t in
                t.column("id", .text).primaryKey()
                t.column("courseID", .text).notNull().indexed().references("Course", onDelete: .cascade)
                t.column("studentID", .text).notNull().indexed().references("Student", onDelete: .cascade)
            }
            try db.create(table: "Attendance") { t in
                t.column("id", .text).primaryKey()
                t.column("courseId", .text).notNull().indexed().references("Course", onDelete: .cascade)
                t.column("date", .double).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(table: "AttendanceRecord") { t in
                t.column("id", .text).primaryKey()
                t.column("attendanceId", .text).notNull().indexed().references("Attendance", onDelete: .cascade)
                t.column("studentId", .text).notNull().indexed().references("Student", onDelete: .cascade)
                t.column("statusId", .text).notNull().indexed().references("Status", onDelete: .cascade)
            }
            try db.create(table: "AttendanceNote") { t in
                t.column("id", .text).primaryKey()
                t.column("attendanceId", .text).notNull().indexed().references("Attendance", onDelete: .cascade)
                t.column("text", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
            try db.create(table: "StudentNote") { t in
                t.column("id", .text).primaryKey()
                t.column("studentId", .text).notNull().indexed().references("Student", onDelete: .cascade)
                t.column("text", .text).notNull()
                t.column("createdAt", .double).notNull()
            }
        }
        return migrator
    }
}
