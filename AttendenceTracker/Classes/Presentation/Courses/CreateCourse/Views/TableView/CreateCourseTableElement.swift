//
//  CreateCourseTableElement.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

enum CreateCourseTableElement {
    case title
    case student(CreateCourseTableStudentElement)
}

final class CreateCourseTableStudentElement {
    let student: Student
    var checked: Bool
    
    init(student: Student, checked: Bool) {
        self.student = student
        self.checked = checked
    }
}
