//
//  StudentNotesEmptyView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentNotesEmptyView: UIView {
    lazy var imageView = makeImageView()
    lazy var label = makeLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension StudentNotesEmptyView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
}

// MARK: Make constraints
private extension StudentNotesEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 128.scale),
            imageView.heightAnchor.constraint(equalToConstant: 128.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 144.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension StudentNotesEmptyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 24.scale
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Students.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.semiBold(size: 16.scale))
            .lineHeight(21.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "StudentNotes.Empty".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
