//
//  MainTabItemButton.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit

final class MainTabItemButton: UIButton {
    enum Tab {
        case courses, students, settings
    }
    
    enum Mode {
        case selected, deselected
    }
    
    lazy var label = makeLabel()
    
    var mode = Mode.deselected {
        didSet {
            update()
        }
    }
    
    let tab: Tab
    
    init(tab: Tab) {
        self.tab = tab
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MainTabItemButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func update() {
        label.alpha = mode == .selected ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension MainTabItemButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainTabItemButton {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.bold(size: 14.scale))
            .lineHeight(19.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = tab.title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension MainTabItemButton.Tab {
    var title: String {
        switch self {
        case .courses:
            return "Main.Courses".localized
        case .students:
            return "Main.Students".localized
        case .settings:
            return "Main.Settings".localized
        }
    }
}
