//
//  Task.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import RealmSwift

class Task: ObservableObject, Identifiable {
    @Published var _id = ObjectId()
    @Published var title = ""
    @Published var description = ""
    @Published var startDate = Date()
    @Published var completedDate: Date?
    @Published var cancelDate: Date?
    @Published var renewals = [Renewal]()
    @Published var deadlineDate = Date().addingTimeInterval(86400)
    @Published var donateOnFailure = true
    @Published var charities = [ObjectId]()
    @Published var tags = [String]()
    
    var id: String { _id.stringValue }

    convenience init(
        _id: ObjectId = ObjectId(),
        title: String,
        description: String,
        startDate: Date = Date(),
        cancelDate: Date? = nil,
        renewals: [Renewal] = [],
        deadlineDate: Date,
        donateOnFailure: Bool,
        charities: [ObjectId] = [],
        tags: [String]
    ) {
        self.init()
        self._id = _id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.cancelDate = cancelDate
        self.renewals.append(contentsOf: renewals)
        self.deadlineDate = deadlineDate
        self.donateOnFailure = donateOnFailure
        self.charities.append(contentsOf: charities)
        self.tags.append(contentsOf: tags)
    }
}
