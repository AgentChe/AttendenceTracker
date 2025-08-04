//
//  CourseStatus.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct CourseStatus: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let courseId: String
    let statusId: String
}
