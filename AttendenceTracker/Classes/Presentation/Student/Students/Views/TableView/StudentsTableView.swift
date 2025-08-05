//
//  StudentsTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class StudentsTableView: UITableView {
    private lazy var elements = [Student]()
    
    private lazy var didSelectTrigger = PublishRelay<Student>()
    private lazy var didDeleteTrigger = PublishRelay<Student>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension StudentsTableView {
    func setup(elements: [Student]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Student> {
        didSelectTrigger.asSignal()
    }
    
    var didDelete: Signal<Student> {
        didDeleteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension StudentsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: StudentsTableCell.self), for: indexPath) as! StudentsTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension StudentsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            guard let self else { return }
            
            let student = elements[indexPath.row]
            
            elements.remove(at: indexPath.row)
            
            deleteRows(at: [indexPath], with: .automatic)
            
            didDeleteTrigger.accept(student)
            
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: Private
private extension StudentsTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: 16.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(StudentsTableCell.self, forCellReuseIdentifier: String(describing: StudentsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
