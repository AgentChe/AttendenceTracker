//
//  StudentNoteView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentNoteView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var label = makeLabel()
    
    private let studentNote: StudentNote
    
    init(studentNote: StudentNote) {
        self.studentNote = studentNote
        
        super.init(frame: .zero)
        
        makeContraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension StudentNoteView {
    func initialize() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 24.scale
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}

// MARK: Make constraints
private extension StudentNoteView {
    func makeContraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension StudentNoteView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.contentInset = UIEdgeInsets(vertical: 24.scale)
        view.setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
            .lineBreakMode(.byTruncatingTail)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = studentNote.text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
}
