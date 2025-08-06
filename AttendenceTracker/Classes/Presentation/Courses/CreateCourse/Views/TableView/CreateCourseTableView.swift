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
    private lazy var didChangeSelectedStudentTrigger = PublishRelay<(Student, Bool)>()
    
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
    
    var didChangeSelectedStudent: Signal<(Student, Bool)> {
        didChangeSelectedStudentTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension CreateCourseTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .title:
            let cell = dequeueReusableCell(withIdentifier: String(describing: CCStudentsTitleCell.self), for: indexPath) as! CCStudentsTitleCell
            cell.didTapAdd = { [weak self] in
                self?.didTapAddStudentTrigger.accept(Void())
            }
            return cell
        case .student(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: CCStudentCell.self), for: indexPath) as! CCStudentCell
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
        guard case .student(let element) = elements[indexPath.row] else { return }
        
        element.checked.toggle()
        
        reloadRows(at: [indexPath], with: .automatic)
        
        didChangeSelectedStudentTrigger.accept((element.student, element.checked))
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
        
        register(CCStudentsTitleCell.self, forCellReuseIdentifier: String(describing: CCStudentsTitleCell.self))
        register(CCStudentCell.self, forCellReuseIdentifier: String(describing: CCStudentCell.self))
        
        dataSource = self
        delegate = self
    }
}
