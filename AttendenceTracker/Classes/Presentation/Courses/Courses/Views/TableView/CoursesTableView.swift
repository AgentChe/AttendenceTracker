//
//  CoursesTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CoursesTableView: UITableView {
    private lazy var elements = [Course]()
    
    private lazy var didSelectTrigger = PublishRelay<Course>()
    private lazy var didDeleteTrigger = PublishRelay<Course>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CoursesTableView {
    func setup(elements: [Course]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Course> {
        didSelectTrigger.asSignal()
    }
    
    var didDelete: Signal<Course> {
        didDeleteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CoursesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: CoursesTableCell.self), for: indexPath) as! CoursesTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension CoursesTableView: UITableViewDelegate {
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
private extension CoursesTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: 16.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(CoursesTableCell.self, forCellReuseIdentifier: String(describing: CoursesTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
