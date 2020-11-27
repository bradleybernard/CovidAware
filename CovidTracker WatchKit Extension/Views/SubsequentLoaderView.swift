//
//  SubsequentLoaderView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/25/20.
//

import SwiftUI

// Static stored properties not supported in generic types
enum SubsequentLoaderViewConstants {
    static let transition = AnyTransition.opacity.combined(with: .move(edge: .top))
    static let height: CGFloat = 30
    static let topPadding: CGFloat = 8
    static let leadingPadding: CGFloat = 12
    static let progressViewScale: CGFloat = 0.5
    static let cornerRadius: CGFloat = 22
}

struct SubsequentLoaderView<ViewModelType: RefreshableViewModel>: View {
    let reader: GeometryProxy
    let viewModel: SubsequentLoaderViewModel<ViewModelType>

    var body: some View {
        Button(action: {
            viewModel.refreshableViewModel.updateData()
        }, label: {
            HStack(alignment: .center, spacing: 0) {
                Text(viewModel.text)
                    .padding(.init(top: 0, leading: SubsequentLoaderViewConstants.leadingPadding, bottom: 0, trailing: viewModel.textRightInset))
                    .layoutPriority(1)

                if viewModel.viewState == .subsequentLoad {
                    ProgressView()
                        .scaleEffect(SubsequentLoaderViewConstants.progressViewScale, anchor: .center)
                        .fixedSize()
                        .padding(.init(top: 0, leading: 0, bottom: 0, trailing: viewModel.progressRightInset))
                        .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                }
            }
        })
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: SubsequentLoaderViewConstants.cornerRadius)
                .fill(viewModel.backgroundColor)
                .frame(width: reader.size.width, height: SubsequentLoaderViewConstants.height)
        )
        .animation(.default)
        .transition(.asymmetric(insertion: SubsequentLoaderViewConstants.transition, removal: SubsequentLoaderViewConstants.transition))
    }
}
