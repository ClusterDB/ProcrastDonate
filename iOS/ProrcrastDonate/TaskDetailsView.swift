//
//  TaskDetailsView.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct TaskDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var task: Task
    
    @State var showingTagInput = false
    @State var newTag = ""
    
    let tagRows = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        NavigationView {
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
                    CaptionLabel("When to Donate")
                    Picker(selection: $task.donateOnFailure, label: Text("When should the donation be made?")) {
                        Text("Completion").tag(false)
                        Text("Expiration").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    NumberInputField(title: "Donation Amount", value: $task.donationAmount.amount)
                    CharityView(charityID: $task.charity)
                }
                Group {
                    CaptionLabel("Tags")
                    ScrollView {
                        LazyVGrid(columns: tagRows, spacing: 8) {
                            ForEach(task.tags, id: \.self) { tag in
                                Tag(tag) {
                                    task.tags = task.tags.filter { $0 != tag }
                                }
                            }
                            AddTag {
                                showingTagInput.toggle()
                            }
                        }
                    }
                    if showingTagInput {
                        InputBox(placeholder: "New tag", newText: $newTag, action: addTag)
                    }
                }
                .padding(.top, 8)
                Spacer()
            }
            .padding()
            .navigationBarTitle(task.title, displayMode: .inline)
            .navigationBarItems(
                trailing: Button(
                    action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done") })
            .animation(.easeIn)
        }
    }
    
    func addTag() {
        task.tags.append(newTag)
        newTag = ""
        showingTagInput = false
    }
    
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsView(task: .sample)
    }
}
