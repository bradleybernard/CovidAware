//
//  RefreshableViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/17/20.
//

import Foundation
import Combine

class RefreshableViewModel: ViewModel {
    enum FetchOrigin {
        case inApp
        case backgroundTask(urlSession: URLSession)
    }

    var identifier: String {
        "ViewModel"
    }

    var cancellables: [AnyCancellable] = []
    var lastFetchedDate: Date?
    let calendar: Calendar = .current
    let dataIntervalInMinutes = 15

    override init() {
        super.init()
        ViewModelManager.shared.add(viewModel: self)
    }

    deinit {
        ViewModelManager.shared.remove(viewModel: self)
    }

    func initialLoad() {
        viewState = .initialLoad
        fetchData(origin: .inApp)
    }

    func fetchData(origin: FetchOrigin) {
        preconditionFailure("Must be overriden in subclass")
    }

    func updateData() {
        preconditionFailure("Must be overriden in subclass")
    }

    func receiveCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
            case .failure:
                viewState = .error
            case .finished:
                break
        }
    }

    func handleBackgroundData(data: Data) {
        preconditionFailure("Must be overriden in subclass")
    }

    func checkForNewData() {
        guard viewState == .content, shouldCheckForNewData else {
            return
        }

        viewState = .subsequentLoad
        fetchData(origin: .inApp)
    }

    var shouldCheckForNewData: Bool {
        guard let checkedDate = lastFetchedDate else {
            return true
        }

        let timeComponents = calendar.dateComponents([.hour, .minute], from: checkedDate)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())

        guard let difference = calendar.dateComponents([.minute], from: timeComponents, to: nowComponents).minute else {
            return false
        }

        return difference >= dataIntervalInMinutes
    }
}
