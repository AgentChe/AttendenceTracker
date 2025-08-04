//
//  AttendanceRecord.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct AttendanceRecord: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let attendanceId: String
    let studentId: String
    let statusId: String
}
