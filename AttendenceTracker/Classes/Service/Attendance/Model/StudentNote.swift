//
//  StudentNote.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 02.08.2025.
//

import GRDB

struct StudentNote: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let studentId: String
    let text: String
    let createdAt: TimeInterval
}
