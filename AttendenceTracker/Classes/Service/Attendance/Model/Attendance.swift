//
//  Attendance.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct Attendance: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let courseId: String
    let date: TimeInterval
    let createdAt: TimeInterval
}
