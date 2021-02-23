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
            Spacer()
        }
        .padding()
        .navigationBarTitle(task.title, displayMode: .inline)
    }
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskDetailsView(task: .sample)
                .environmentObject(AppState())
        }
    }
}
