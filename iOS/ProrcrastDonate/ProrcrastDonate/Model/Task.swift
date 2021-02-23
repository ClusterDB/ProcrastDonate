//
//  Task.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import Foundation
import RealmSwift

@objcMembers class Task: Object, ObjectKeyIdentifiable {
    dynamic var _id = ObjectId()
    dynamic var title = ""
    dynamic var taskDescription = "" // Can't use "description" as it's used by the base protocol
    dynamic var startDate = Date()
    dynamic var completedDate: Date?
    dynamic var cancelDate: Date?
    var renewals = List<Renewal>()
    dynamic var deadlineDate = Date().addingTimeInterval(86400)
    dynamic var donateOnFailure = true
    var charities = List<ObjectId>()
    var tags = List<String>()

    convenience init(
        _id: ObjectId = ObjectId(),
        title: String,
        taskDescription: String,
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
        self.taskDescription = taskDescription
        self.startDate = startDate
        self.cancelDate = cancelDate
        for renewal in renewals {
            self.renewals.append(renewal)
        }
        self.deadlineDate = deadlineDate
        self.donateOnFailure = donateOnFailure
        for charity in charities {
            self.charities.append(charity)
        }
        for tag in tags {
            self.tags.append(tag)
        }

    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
