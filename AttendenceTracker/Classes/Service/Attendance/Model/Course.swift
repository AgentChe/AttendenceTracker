//
//  Course.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import GRDB

struct Course: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let createdAt: TimeInterval
}
