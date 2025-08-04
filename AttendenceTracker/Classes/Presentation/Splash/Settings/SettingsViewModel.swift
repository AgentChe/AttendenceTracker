//
//  SettingsViewModel.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 04.08.2025.
//

import RxSwift
import RxCocoa

final class SettingsViewModel {
    enum Action {
        case openStatuses
        case openURL(URL)
    }
}

// MARK: Public
extension SettingsViewModel {
    struct Input {
        let didSelect: Signal<SettingsTableElement>
    }
    
    struct Output {
        let elements: Driver<[SettingsTableElement]>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(),
            action: makeAction(didSelect: input.didSelect)
        )
    }
}

// MARK: Private
private extension SettingsViewModel {
    func makeElements() -> Driver<[SettingsTableElement]> {
        .deferred {
            .just([
                .statuses,
                .termsOfUse,
                .privacyPolicy,
                .contactUs
            ])
        }
    }
    
    func makeAction(didSelect: Signal<SettingsTableElement>) -> Driver<Action> {
        didSelect
            .map { element -> Action in
                switch element {
                case .statuses:
                    return .openStatuses
                case .termsOfUse:
                    return .openURL(GlobalDefinitions.termsOfServiceUrl)
                case .privacyPolicy:
                    return .openURL(GlobalDefinitions.privacyPolicyUrl)
                case .contactUs:
                    return .openURL(GlobalDefinitions.contactUsUrl)
                }
            }
            .asDriver(onErrorDriveWith: .never())
    }
}
