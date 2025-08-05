//
//  CreateStudentNoteViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import RxSwift
import RxCocoa

final class CreateStudentNoteViewModel {
    enum Action {
        case close
    }
    
    private let student: Driver<Student>
    
    private lazy var attendanceManager = AttendanceManager()
    
    init(student: Student) {
        self.student = BehaviorRelay(value: student).asDriver()
    }
}

// MARK: Public
extension CreateStudentNoteViewModel {
    struct Input {
        let didCreate: Signal<String>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                student: student,
                didCreate: input.didCreate
            )
        )
    }
}

// MARK: Private
private extension CreateStudentNoteViewModel {
    func makeAction(student: Driver<Student>, didCreate: Signal<String>) -> Driver<Action> {
        didCreate
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(student) { ($0, $1) }
            .flatMapLatest { [weak self] text, student -> Driver<Action> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .createStudentNote(
                        studentId: student.id,
                        text: text
                    )
                    .map { _ in Action.close }
                    .asDriver(onErrorDriveWith: .never())
            }
    }
}
