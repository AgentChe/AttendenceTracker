//
//  MainCoordinator.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit

final class MainViewCoordinator {
    lazy var coursesVC = UIViewController()
    lazy var studentsVC = UIViewController()
    lazy var settingsVC = UIViewController()
    
    private weak var parentVC: UIViewController?
    private weak var container: UIView?
    
    private var previousVC: UIViewController?
    
    init(parentVC: UIViewController, container: UIView) {
        self.parentVC = parentVC
        self.container = container
    }
}

// MARK: Public
extension MainViewCoordinator {
    func change(tab: MainTabItemButton.Tab) {
        switch tab {
        case .courses:
            changeVC(on: coursesVC)
        case .students:
            changeVC(on: studentsVC)
        case .settings:
            changeVC(on: settingsVC)
        }
    }
}

// MARK: Private
private extension MainViewCoordinator {
    func changeVC(on vc: UIViewController) {
        if let previousVC = self.previousVC {
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
        }
    
        self.previousVC = vc
        
        guard let parentVC, let container else {
            return
        }
    
        parentVC.addChild(vc)
        vc.view.frame = container.bounds
        container.addSubview(vc.view)
        vc.willMove(toParent: parentVC)
    }
}
