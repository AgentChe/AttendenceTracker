//
//  Enrollment.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct Enrollment: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let courseID: String
    let studentID: String
}
