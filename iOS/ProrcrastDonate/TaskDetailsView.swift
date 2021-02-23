//
//  TaskDetailsView.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct TaskDetailsView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var task: Task

    var body: some View {
        VStack {
            InputField(title: "Task Name", text: $task.title)
            TextEditorField(title: "Task Description", text: $task.descriptionText)
            Group {
                CaptionLabel("Dates")
                DatePicker(selection: $task.startDate) {
                    Text("Start")
                }
                DatePicker(selection: $task.deadlineDate) {
                    Text("Deadline")
                }
                if let completedDate = task.completedDate {
                    LabelledDate(title: "Completed", date: completedDate)
                }
                if let cancelDate = task.cancelDate {
                    LabelledDate(title: "Cancelled", date: cancelDate)
                }
            }
            Group {
                CaptionLabel("Donation")
                Toggle("Make donation when task expires", isOn: $task.donateOnFailure)
                if task.donateOnFailure {
                    NumberInputField(title: "Donation Amount", value: $task.donationAmount)
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle(task.title, displayMode: .inline)
    }
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskDetailsView(task: .sample3)
                .environmentObject(AppState())
        }
    }
}
