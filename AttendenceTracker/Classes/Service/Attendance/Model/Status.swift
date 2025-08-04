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
     let color: Color
     let createdAt: TimeInterval
 }
