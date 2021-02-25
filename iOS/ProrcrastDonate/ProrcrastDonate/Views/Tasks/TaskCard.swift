//
//  TaskCard.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI

struct TaskCard: View {
    @ObservedObject var task: Task
    var action: () -> Void = {}
    
    @State private var showingDetails = false
    
    private var isOverDue: Bool { task.deadlineDate.timeIntervalSinceNow < 0 }
    
    var body: some View {
        let completed = Binding(
            get: { return task.completedDate != nil },
            set: {
                task.completedDate = $0 ? Date() : nil
                updateBackend()
            }
        )
        
        return HStack {
            CheckBox(isChecked: completed)
            Button(action: { showingDetails.toggle() }) {
                HStack {
                    Text("\(task.title)")
                    Spacer()
                    if let amount = task.donationAmount {
                        Text("$\(amount.amount)")
                    }
                    VStack(spacing: 0) {
                        Text(task.deadlineDate, style: .relative)
                            .font(.caption)
                            .padding(.bottom, 4)
                        TagGrid(task.tags)
                    }
                }
            }
        }
        .foregroundColor(!completed.wrappedValue && isOverDue ? .red : .primary)
        .opacity(completed.wrappedValue ? 0.3 : 1.0)
        .animation(.easeIn)
        .sheet(isPresented: $showingDetails) {
            TaskDetailsView(task: task)
        }
        .onChange(of: showingDetails, perform: { value in
            if !value {
                action()
                updateBackend()
            }
        })
    }
    
    func updateBackend() {
        action()
        // TODO: Send update to API
        print("Updating backend")
    }
    
}

struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ForEach(Task.samples) { task in
                    TaskCard(task: task)
                }
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
