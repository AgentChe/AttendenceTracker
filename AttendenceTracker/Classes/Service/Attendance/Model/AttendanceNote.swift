//
//  AttendanceNote.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct AttendanceNote: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let attendanceId: String
    let text: String
    let createdAt: TimeInterval
}
