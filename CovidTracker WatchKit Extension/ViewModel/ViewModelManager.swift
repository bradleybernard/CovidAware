//
//  ViewModelManager.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/16/20.
//

import Foundation
import WatchKit

class ViewModelManager {
    static let shared = ViewModelManager()

    private let viewModels: NSHashTable<RefreshableViewModel>

    init() {
        viewModels = NSHashTable<RefreshableViewModel>.weakObjects()
    }

    func add(viewModel: RefreshableViewModel) {
        viewModels.add(viewModel)
    }

    func remove(viewModel: RefreshableViewModel) {
        viewModels.remove(viewModel)
    }

    func downloadTaskCompleted(_ downloadTask: URLSessionDownloadTask, with data: Data) {
        guard let url = downloadTask.currentRequest?.url else {
            preconditionFailure("Download task URL cannot be nil")
        }

        let viewModel = findViewModel(for: url)

        DispatchQueue.main.async {
            viewModel?.handleBackgroundData(data: data)
        }
    }

    private func findViewModel(for url: URL) -> RefreshableViewModel? {
        guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
            preconditionFailure("URL components for background task cannot be nil")
        }

        guard let queryItems = urlComponents.queryItems else {
            preconditionFailure("Query items in URL components cannot be nil")
        }

        guard let identifierQueryItem = queryItems.first(where: { queryItem in
            queryItem.name == Endpoint.identifierKey
        }) else {
            preconditionFailure("Identifier query item cannot be nil")
        }

        let viewModelClass: RefreshableViewModel.Type = {
            switch identifierQueryItem.value {
                case Endpoint.USToday.identifier:
                    return USTodayViewModel.self
                // Can be any state, just need identifier for state detail
                case Endpoint.stateDetail(USAState: .alaska).identifier:
                    return StateDetailViewModel.self
                default:
                    preconditionFailure("Identifier query item value needs to match an endpoint identifier")
            }
        }()

        return viewModels.allObjects.first { viewModel in
            type(of: viewModel) == viewModelClass
        }
    }

    func triggerBackgroundRefresh(urlSession: URLSession, completion: () -> Void) {
        viewModels.allObjects.forEach { viewModel in
            viewModel.fetchData(origin: .backgroundTask(urlSession: urlSession))
        }

        completion()
    }
}
