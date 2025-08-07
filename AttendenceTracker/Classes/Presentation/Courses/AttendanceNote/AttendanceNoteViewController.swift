//
//  AttendanceNoteViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit

final class AttendanceNoteViewController: UIViewController {
    private let mainView: AttendanceNoteView
    
    private init(attendanceNote: AttendanceNote) {
        mainView = AttendanceNoteView(attendanceNote: attendanceNote)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
}

// MARK: Public
extension AttendanceNoteViewController {
    static func make(attendanceNote: AttendanceNote) -> AttendanceNoteViewController {
        let vc = AttendanceNoteViewController(attendanceNote: attendanceNote)
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("small"), resolver: { _ in 250.scale })]
            sheet.selectedDetentIdentifier = .init("small")
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24.scale
        }
        
        return vc
    }
}
