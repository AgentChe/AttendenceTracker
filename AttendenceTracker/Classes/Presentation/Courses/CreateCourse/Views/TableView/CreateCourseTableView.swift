//
//  CreateCourseTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 06.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateCourseTableView: UITableView {
    private lazy var elements = [CreateCourseTableElement]()
    
    private lazy var didTapAddStudentTrigger = PublishRelay<Void>()
    private lazy var didTapAddStatusTrigger = PublishRelay<Void>()
    private lazy var didChangeSelectedStudentTrigger = PublishRelay<(Student, Bool)>()
    private lazy var didChangeSelectedStatusTrigger = PublishRelay<(Status, Bool)>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension CreateCourseTableView {
    func setup(elements: [CreateCourseTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapAddStudent: Signal<Void> {
        didTapAddStudentTrigger.asSignal()
    }
    
    var didTapAddStatus: Signal<Void> {
        didTapAddStatusTrigger.asSignal()
    }
    
    var didChangeSelectedStudent: Signal<(Student, Bool)> {
        didChangeSelectedStudentTrigger.asSignal()
    }
    
    var didChangeSelectedStatus: Signal<(Status, Bool)> {
        didChangeSelectedStatusTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CreateCourseTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CreateCourseTitleCell.self), for: indexPath) as! CreateCourseTitleCell
            cell.setup(element: element)
            cell.didTapAdd = { [weak self] in
                switch element {
                case .students:
                    self?.didTapAddStudentTrigger.accept(Void())
                case .statuses:
                    self?.didTapAddStatusTrigger.accept(Void())
                }
            }
            return cell
        case .student(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CreateCourseCell.self), for: indexPath) as! CreateCourseCell
            cell.setup(element: element)
            return cell
        case .status(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CreateCourseCell.self), for: indexPath) as! CreateCourseCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension CreateCourseTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .title:
            break
        case .student(let element):
            element.checked.toggle()
            
            reloadRows(at: [indexPath], with: .automatic)
            
            didChangeSelectedStudentTrigger.accept((element.student, element.checked))
        case .status(let element):
            element.checked.toggle()
            
            reloadRows(at: [indexPath], with: .automatic)
            
            didChangeSelectedStatusTrigger.accept((element.status, element.checked))
        }
    }
}

// MARK: Private
private extension CreateCourseTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 24.scale)
        setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(CreateCourseTitleCell.self, forCellReuseIdentifier: String(describing: CreateCourseTitleCell.self))
        register(CreateCourseCell.self, forCellReuseIdentifier: String(describing: CreateCourseCell.self))
        
        dataSource = self
        delegate = self
    }
}
