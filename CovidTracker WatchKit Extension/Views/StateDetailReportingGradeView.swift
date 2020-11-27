//
//  StateDetailReportingGradeView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/14/20.
//

import SwiftUI

struct StateDetailReportingGradeView: View {
    let reportingGrade: ReportingGrade?

    @State private var isPresented = false

    var body: some View {
        if let reportingGrade = reportingGrade {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text("Data quality grade")
                    .font(Font.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)

                Spacer()

                ReportingGradeView(reportingGrade: reportingGrade)
            })
            .sheet(isPresented: $isPresented) {
                InfoView(
                    title: "Data quality grade",
                    description: "To help members of the public understand how well each state is performing, we have assigned each state a data-quality grade based on our assessment of the completeness of their reporting.")
            }
        }
    }
}

#if DEBUG
struct StateDetailReportingGradeView_Previews: PreviewProvider {
    static var previews: some View {
        StateDetailReportingGradeView(reportingGrade: .mock)
    }
}
#endif
