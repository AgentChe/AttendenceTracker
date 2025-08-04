//
//  StatusesTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class StatusesTableView: UITableView {
    private lazy var elements = [StatusesTableElement]()
    
    private lazy var didLongPressTrigger = PublishRelay<Status>()
    private lazy var didDeleteTrigger = PublishRelay<Status>()
    private lazy var didAttemptDeleteSystemStatusTrigger = PublishRelay<Status>()
    
    private lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension StatusesTableView {
    func setup(elements: [StatusesTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didLongPress: Signal<Status> {
        didLongPressTrigger.asSignal()
    }
    
    var didDelete: Signal<Status> {
        didDeleteTrigger.asSignal()
    }
    
    var didAttemptDeleteSystemStatus: Signal<Status> {
        didAttemptDeleteSystemStatusTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension StatusesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: StatusesTableCell.self), for: indexPath) as! StatusesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension StatusesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            guard let self else { return }
            
            let status = elements[indexPath.row].status
            
            if status.isSystem {
                didAttemptDeleteSystemStatusTrigger.accept(status)
            } else {
                elements.remove(at: indexPath.row)
                
                deleteRows(at: [indexPath], with: .automatic)
                
                didDeleteTrigger.accept(status)
            }
            
            completion(!status.isSystem)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: Private
private extension StatusesTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: 16.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(StatusesTableCell.self, forCellReuseIdentifier: String(describing: StatusesTableCell.self))
        
        dataSource = self
        delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.require(toFail: panGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
        
        longPressRecognizer.rx.event
            .compactMap { [weak self] gesture -> Status? in
                guard let self, gesture.state == .began else { return nil }
                
                let touchPoint = gesture.location(in: self)
                
                if let indexPath = indexPathForRow(at: touchPoint) {
                    return elements[indexPath.row].status
                }
                
                return nil
            }
            .bind(to: didLongPressTrigger)
            .disposed(by: disposeBag)
    }
}
