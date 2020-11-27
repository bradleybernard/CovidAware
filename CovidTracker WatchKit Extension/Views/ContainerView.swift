//
//  ContainerView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/28/20.
//

import SwiftUI

struct ContainerView<Content: View, ViewModelType: RefreshableViewModel>: View {
    let viewModel: ViewModelType
    let content: Content

    var body: some View {
        switch viewModel.viewState {
            case .initialLoad:
                ProgressView("Loading data")
                    .onAppear {
                        viewModel.initialLoad()
                    }
            case .error:
                TryAgainView(kind: .error) {
                    viewModel.initialLoad()
                }
            case .empty:
                TryAgainView(kind: .noData) {
                    viewModel.initialLoad()
                }
            case .content, .subsequentLoad, .newContentAvailable:
                contentView.onAppear {
                    viewModel.checkForNewData()
                }
        }
    }

    private var contentView: some View {
        GeometryReader { reader in
            ZStack {
                content
                    .zIndex(0)

                if viewModel.viewState.shouldShowSubsequentLoader {
                    SubsequentLoaderView(reader: reader, viewModel: SubsequentLoaderViewModel(viewModel: viewModel))
                        .offset(y: -(reader.size.height / 2) + (SubsequentLoaderViewConstants.height / 2) + SubsequentLoaderViewConstants.topPadding)
                        .zIndex(1)
                        .animation(.default)
                }
            }
        }
    }
}
