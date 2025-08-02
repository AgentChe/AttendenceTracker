//
//  Attendance.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import Foundation

struct Attendance {
    struct Record {
        let id: String
        let studentId: String
        let statusId: String
    }

    let id: String
    let courseId: String
    let date: TimeInterval
    let records: [Record]
}
