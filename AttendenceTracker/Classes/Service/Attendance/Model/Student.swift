//
//  Student.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import GRDB

struct Student: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let createdAt: TimeInterval
}
