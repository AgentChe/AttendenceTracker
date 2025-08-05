//
//  StudentNoteViewController.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentNoteViewController: UIViewController {
    private let mainView: StudentNoteView
    
    private init(studentNote: StudentNote) {
        mainView = StudentNoteView(studentNote: studentNote)
        
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
extension StudentNoteViewController {
    static func make(studentNote: StudentNote) -> StudentNoteViewController {
        let vc = StudentNoteViewController(studentNote: studentNote)
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
