//
//  TaskCard.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI
import SwiftBSON

struct TaskCard: View {
    @EnvironmentObject var state: AppState
    
    @ObservedObject var task: Task
    var action: () -> Void = {}
    
    @State private var showingDetails = false
    
    private var isOverDue: Bool { task.deadlineDate.timeIntervalSinceNow < 0 }
    
    var body: some View {
        let completed = Binding(
            get: { return task.completedDate != nil },
            set: {
                task.completedDate = $0 ? Date() : nil
                if $0 { sendCompletion() }
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
    
    func sendCompletion() {
        action()
        guard let encoded = try? ExtendedJSONEncoder().encode("mark-as-completed") else {
            print("Failed to encode completion request")
            return
        }
        guard let url = URL(string: "\(state.APIURL)tasks/\(task._id.description)") else {
            print("Failed to encode URL")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PATCH"
        request.httpBody = encoded
        URLSession.shared.dataTask(with: request) { data, _, error in
            if data == nil {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
            } else {
                print("Completion sent")
            }
        }.resume()
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
            .environmentObject(AppState())
            .previewLayout(.sizeThatFits)
        }
    }
}
