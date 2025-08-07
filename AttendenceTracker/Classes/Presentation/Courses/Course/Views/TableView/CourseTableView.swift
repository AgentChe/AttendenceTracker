//
//  CourseTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CourseTableView: UITableView {
    private lazy var elements = [Attendance]()
    
    private lazy var didSelectTrigger = PublishRelay<Attendance>()
    private lazy var didDeleteTrigger = PublishRelay<Attendance>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CourseTableView {
    func setup(elements: [Attendance]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Attendance> {
        didSelectTrigger.asSignal()
    }
    
    var didDelete: Signal<Attendance> {
        didDeleteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CourseTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: CourseTableCell.self), for: indexPath) as! CourseTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension CourseTableView: UITableViewDelegate {
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
private extension CourseTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: 16.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(CourseTableCell.self, forCellReuseIdentifier: String(describing: CourseTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
