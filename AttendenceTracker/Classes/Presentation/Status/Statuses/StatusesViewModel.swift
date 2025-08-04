//
//  StatusesViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import RxSwift
import RxCocoa

final class StatusesViewModel {
    enum Action {
        case createStatus
        case showToast(String)
    }
    
    private lazy var attendanceManager = AttendanceManager()
}

// MARK: Public
extension StatusesViewModel {
    struct Input {
        let didTapCreateStatus: Signal<Void>
        let didLongPressStatus: Signal<Status>
        let didDeleteStatus: Signal<Status>
        let didAttemptDeleteSystemStatus: Signal<Status>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[StatusesTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let statuses = makeStatuses(didDeleteStatus: input.didDeleteStatus)
        let defaultStatus = makeDefaultStatus(didLongPressStatus: input.didLongPressStatus)
        
        return Output(
            action: makeAction(
                didTapCreateStatus: input.didTapCreateStatus,
                didAttemptDeleteSystemStatus: input.didAttemptDeleteSystemStatus
            ),
            elements: makeElements(
                statuses: statuses,
                defaultStatus: defaultStatus
            )
        )
    }
}

// MARK: Private
private extension StatusesViewModel {
    func makeAction(
        didTapCreateStatus: Signal<Void>,
        didAttemptDeleteSystemStatus: Signal<Status>
    ) -> Driver<Action> {
        let createStatus = didTapCreateStatus
            .map { Action.createStatus }
            .asDriver(onErrorDriveWith: .never())
        
        let attemptDeleteSystemStatus = didAttemptDeleteSystemStatus
            .map { status -> Action in
                let string = String(format: "Statuses.AttemptDeleteSystemStatus".localized, status.title)
                return .showToast(string)
            }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(createStatus, attemptDeleteSystemStatus)
    }
    
    func makeElements(
        statuses: Driver<[Status]>,
        defaultStatus: Driver<Status?>
    ) -> Driver<[StatusesTableElement]> {
        Driver
            .combineLatest(statuses, defaultStatus)
            .map { statuses, defaultStatus -> [StatusesTableElement] in
                statuses.map { status -> StatusesTableElement in
                    StatusesTableElement(
                        status: status,
                        isDefault: status.id == defaultStatus?.id
                    )
                }
            }
    }
    
    func makeStatuses(didDeleteStatus: Signal<Status>) -> Driver<[Status]> {
        enum Action {
            case initial([Status])
            case created(Status)
            case deleted(String)
        }
        
        let initial = attendanceManager
            .fetchAllStatuses()
            .asDriver(onErrorJustReturn: [])
        
        return initial
            .flatMapLatest { initialStatuses -> Driver<[Status]> in
                let created = AttendanceMediator.shared.didCreatedStatus
                    .map { Action.created($0) }
                    .asDriver(onErrorDriveWith: .never())
                
                let deleted = didDeleteStatus
                    .flatMapLatest { [weak self] status -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return attendanceManager
                            .delete(statusId: status.id)
                            .map { Action.deleted(status.id) }
                            .asDriver(onErrorDriveWith: .never())
                    }
                
                return Driver
                    .merge(created, deleted)
                    .startWith(.initial(initialStatuses))
                    .scan(initialStatuses) { statuses, action -> [Status] in
                        switch action {
                        case .initial(let statuses):
                            return statuses
                        case .created(let status):
                            return statuses + [status]
                        case .deleted(let statusId):
                            var statuses = statuses
                            statuses.removeAll(where: { $0.id == statusId })
                            return statuses
                        }
                    }
                    .map { statuses -> [Status] in
                        statuses.sorted(by: { $0.title < $1.title })
                    }
            }
    }
    
    func makeDefaultStatus(didLongPressStatus: Signal<Status>) -> Driver<Status?> {
        let initial = AttendanceMediator.shared
            .didDeletedStatusId
            .map { _ in Void() }
            .startWith(())
            .flatMapLatest { [weak self] void -> Driver<Status?> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .defaultStatus()
                    .map { status -> Status? in status }
                    .asDriver(onErrorJustReturn: nil)
            }
        
        let changed = didLongPressStatus
            .flatMapLatest { [weak self] status -> Driver<Status?> in
                guard let self else { return .never() }
                
                return attendanceManager
                    .setup(defaultStatus: status)
                    .asDriver(onErrorDriveWith: .never())
                    .map { status }
            }
        
        return Driver
            .merge(initial, changed)
    }
}
