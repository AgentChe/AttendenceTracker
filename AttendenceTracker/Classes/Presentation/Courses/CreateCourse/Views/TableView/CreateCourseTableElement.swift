//
//  CreateCourseTableElement.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

enum CreateCourseTableElement {
    case title(CreateCourseTableTitleElement)
    case student(CreateCourseTableStudentElement)
    case status(CreateCourseTableStatusElement)
}

enum CreateCourseTableTitleElement {
    case students
    case statuses
}

final class CreateCourseTableStudentElement {
    let student: Student
    var checked: Bool
    
    init(student: Student, checked: Bool) {
        self.student = student
        self.checked = checked
    }
}

final class CreateCourseTableStatusElement {
    let status: Status
    var checked: Bool
    
    init(status: Status, checked: Bool) {
        self.status = status
        self.checked = checked
    }
}
