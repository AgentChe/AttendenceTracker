//
//  AttendanceTableView.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 07.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class AttendanceTableView: UITableView {
    private lazy var elements = [AttendanceTableElement]()
    
    private lazy var didTapAddNoteTrigger = PublishRelay<Void>()
    private lazy var didSelectNoteTrigger = PublishRelay<AttendanceNote>()
    private lazy var didDeleteNoteTrigger = PublishRelay<AttendanceNote>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AttendanceTableView {
    func setup(elements: [AttendanceTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapAddNote: Signal<Void> {
        didTapAddNoteTrigger.asSignal()
    }
    
    var didSelectNote: Signal<AttendanceNote> {
        didSelectNoteTrigger.asSignal()
    }
    
    var didDeleteNote: Signal<AttendanceNote> {
        didDeleteNoteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AttendanceTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .notesTitle:
            let cell = dequeueReusableCell(withIdentifier: String(describing: AttendanceTableNotesTitleCell.self), for: indexPath) as! AttendanceTableNotesTitleCell
            cell.didTapAdd = { [weak self] in
                self?.didTapAddNoteTrigger.accept(Void())
            }
            return cell
        case .note(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AttendanceTableNoteCell.self), for: indexPath) as! AttendanceTableNoteCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension AttendanceTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .note(let element):
            didSelectNoteTrigger.accept(element)
        default:
            return 
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch elements[indexPath.row] {
        case .note(let element):
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                guard let self else { return }
                
                elements.remove(at: indexPath.row)
                
                deleteRows(at: [indexPath], with: .automatic)
                
                didDeleteNoteTrigger.accept(element)
                
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        default:
            return nil
        }
    }
}

// MARK: Private
private extension AttendanceTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 24.scale)
        setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        separatorColor = Appearance.mono200.withAlphaComponent(0.2)
        separatorInset = UIEdgeInsets(horizontal: 16.scale)
        showsVerticalScrollIndicator = false
        
        register(AttendanceTableNotesTitleCell.self, forCellReuseIdentifier: String(describing: AttendanceTableNotesTitleCell.self))
        register(AttendanceTableNoteCell.self, forCellReuseIdentifier: String(describing: AttendanceTableNoteCell.self))
        
        dataSource = self
        delegate = self
    }
}
