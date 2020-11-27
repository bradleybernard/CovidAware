//
//  SelectionListView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/3/20.
//

import SwiftUI

struct SelectionListView<Element: Identifiable & Hashable & Equatable, RowContent: View>: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String
    let elements: [Element]
    @Binding var selected: Element?
    let rowContentBuilder: (Element) -> RowContent

    init(title: String, elements: [Element], selected: Binding<Element?>, @ViewBuilder rowContentBuilder: @escaping (Element) -> RowContent) {
        self.title = title
        self.elements = elements
        self._selected = selected
        self.rowContentBuilder = rowContentBuilder
    }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(title.localizedUppercase)
                        .foregroundColor(.gray)
                        .font(.footnote)

                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(elements.indices, id: \.self) { index in
                            Button(action: {
                                selected = elements[index]
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                HStack(alignment: .firstTextBaseline, spacing: 0) {
                                    rowContentBuilder(elements[index])

                                    Spacer()

                                    Text(Image(systemName: "checkmark"))
                                        .font(.body)
                                        .foregroundColor(.green)
                                        .opacity(selected == elements[index] ? 1 : 0)
                                }
                            })
                            .id(index)
                            .animation(.easeInOut(duration: 0.2))
                            .buttonStyle(SelectionButtonStyle(position: .init(position: index, count: elements.count)))
                        }
                    }
                }
            }
            .onAppear {
                let selectedIndex = elements.firstIndex { element -> Bool in
                    selected == element
                }

                reader.scrollTo(selectedIndex, anchor: .center)
            }
        }
    }
}

#if DEBUG
struct SelectionListView_Previews: PreviewProvider {
    static var previews: some View {
        SelectionListView(title: "States", elements: [USAState.california, USAState.maine], selected: .constant(.mock)) { usaState in
            Text(usaState.name)
        }
    }
}
#endif
