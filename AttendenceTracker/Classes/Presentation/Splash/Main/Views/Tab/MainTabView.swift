//
//  MainTabView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit

final class MainTabView: UIView {
    lazy var coursesItemButton = makeItemButton(tab: .courses)
    lazy var studentsItemButton = makeItemButton(tab: .students)
    lazy var settingsItemButton = makeItemButton(tab: .settings)
    
    var selectedTab = MainTabItemButton.Tab.courses {
        didSet {
            update()
        }
    }
    
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
private extension MainTabView {
    func initialize() {
        backgroundColor = Appearance.mono100
    }
    
    func update() {
        coursesItemButton.mode = selectedTab == .courses ? .selected : .deselected
        studentsItemButton.mode = selectedTab == .students ? .selected : .deselected
        settingsItemButton.mode = selectedTab == .settings ? .selected : .deselected
    }
}

// MARK: Make constraints
private extension MainTabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            coursesItemButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            coursesItemButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            coursesItemButton.topAnchor.constraint(equalTo: topAnchor),
            coursesItemButton.widthAnchor.constraint(equalTo: studentsItemButton.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            studentsItemButton.leadingAnchor.constraint(equalTo: coursesItemButton.trailingAnchor),
            studentsItemButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            studentsItemButton.topAnchor.constraint(equalTo: topAnchor),
            studentsItemButton.widthAnchor.constraint(equalTo: settingsItemButton.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            settingsItemButton.leadingAnchor.constraint(equalTo: studentsItemButton.trailingAnchor),
            settingsItemButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            settingsItemButton.topAnchor.constraint(equalTo: topAnchor),
            settingsItemButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MainTabView {
    func makeItemButton(tab: MainTabItemButton.Tab) -> MainTabItemButton {
        let view = MainTabItemButton(tab: tab)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
