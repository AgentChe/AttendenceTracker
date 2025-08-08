//
//  AttendanceTableElement.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

enum AttendanceTableElement {
    case recordsTitle
    case record(AttendanceTableRecordElement)
    case notesTitle
    case note(AttendanceNote)
}

struct AttendanceTableRecordElement {
    let recordId: String
    let student: Student
    let status: Status
}
