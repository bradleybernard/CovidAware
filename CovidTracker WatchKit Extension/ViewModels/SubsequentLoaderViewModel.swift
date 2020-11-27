//
//  SubsequentLoaderViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/28/20.
//

import SwiftUI

class SubsequentLoaderViewModel<ViewModelType: RefreshableViewModel>: ObservableObject {
    let refreshableViewModel: ViewModelType

    init(viewModel: ViewModelType) {
        self.refreshableViewModel = viewModel
    }

    var viewState: ViewState {
        refreshableViewModel.viewState
    }

    var backgroundColor: Color {
        viewState == .subsequentLoad ? Color(Colors.grayBackground) : Color.blue
    }

    var textRightInset: CGFloat {
        viewState == .subsequentLoad ? 0 : 12
    }

    var progressRightInset: CGFloat {
        viewState == .subsequentLoad ? 12 : 0
    }

    var text: String {
        switch viewState {
            case .subsequentLoad:
                return "Loading data"
            case .newContentAvailable:
                return "Reload data"
            default:
                return ""
        }
    }
}
