//
//  Status.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import GRDB

struct Status: Codable, Identifiable, FetchableRecord, PersistableRecord {
    let id: String
    let title: String
    let isSystem: Bool
    let createdAt: TimeInterval
}

// MARK: Public
extension Status {
    static func systems() -> [Status] {
        let present = Status(
            id: "status_system_present",
            title: "Statuses.System.Present".localized,
            isSystem: true,
            createdAt: Date().timeIntervalSince1970
        )
        
        let absent = Status(
            id: "status_system_absent",
            title: "Statuses.System.Absent".localized,
            isSystem: true,
            createdAt: Date().timeIntervalSince1970
        )
        
        return [present, absent]
    }
}
