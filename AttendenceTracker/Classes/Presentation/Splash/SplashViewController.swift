//
//  SplashViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController {
    private lazy var mainView = SplashView()
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkInitialize.observe { [weak self] in
            self?.openMain()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

// MARK: Private
private extension SplashViewController {
    func openMain() {
        guard let window = UIApplication.shared.window else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.openMain()
            }
            
            return
        }
        // TODO
//        window.rootViewController = MainViewController.make(requestReview: false)
    }
}
