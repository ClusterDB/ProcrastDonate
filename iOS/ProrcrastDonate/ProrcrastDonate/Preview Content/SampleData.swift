//
//  SampleData.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import Foundation
import RealmSwift

protocol Samplable {
    associatedtype Item
    static var sample: Item { get }
    static var samples: [Item] { get }
}

extension Date {
    static var random: Date {
        Date(timeIntervalSince1970: (50 * 365 * 24 * 3600 + Double.random(in: 0..<(3600 * 24 * 365))))
    }
}

extension User {
    convenience init(_ user: User) {
        self.init()
        // Don't copy _id
        userName = user.userName
        displayName = user.displayName
        email = user.email
        password = user.password
        bio = user.bio
        friends.append(objectsIn: user.friends)
    }
}

extension User: Samplable {
    static var samples: [User] { [sample, sample2, sample3] }
    static var sample: User {
        User(
            _id: ObjectId("rod-id"),
            userName: "rod",
            displayName: "Rod",
            email: "rod@contoso.com",
            password: "rainbow",
            bio: "Singer from Rod, Jane and Freddy",
            friends: [sample2._id, sample3._id])
    }
    static var sample2: User {
        User(
            _id: ObjectId("jane-id"),
            userName: "jane",
            displayName: "Jane",
            email: "jane@contoso.com",
            password: "rainbow",
            bio: "The best singer from Rod, Jane and Freddy",
            friends: [sample._id, sample3._id])
    }
    static var sample3: User {
        User(
            _id: ObjectId("freddy-id"),
            userName: "freddy",
            displayName: "Freddy",
            email: "freddy@contoso.com",
            password: "rainbow",
            bio: "The other singer from Rod, Jane and Freddy",
            friends: [sample._id, sample2._id])
    }
}

extension Renewal {
    convenience init(_ renewal: Renewal) {
        self.init()
        date = renewal.date
        oldDeadline = renewal.oldDeadline
        newDeadline = renewal.newDeadline
        oldAmount = renewal.oldAmount
        newAmount = renewal.newAmount
        renewReason = renewal.renewReason
        paidOldAmount = renewal.paidOldAmount
    }
}

extension Renewal: Samplable {
    static var samples: [Renewal] { [sample, sample2, sample3] }
    static var sample: Renewal {
        Renewal(
            date: Date(),
            oldDeadline: Date(),
            newDeadline: Date().addingTimeInterval(86400),
            oldAmount: 10,
            newAmount: 15,
            renewReason: "Being lazy",
            paidOldAmount: true)
    }
    static var sample2: Renewal {
        Renewal(
            date: Date(),
            oldDeadline: Date().addingTimeInterval(-86400),
            newDeadline: Date().addingTimeInterval(86400),
            oldAmount: 5,
            newAmount: 10,
            renewReason: "Being super lazy",
            paidOldAmount: false)
    }
    static var sample3: Renewal {
        Renewal(
            date: Date().addingTimeInterval(-46340),
            oldDeadline: Date().addingTimeInterval(-400),
            newDeadline: Date().addingTimeInterval(166400),
            oldAmount: 5,
            newAmount: 0,
            renewReason: "Being super-super lazy",
            paidOldAmount: false)
    }
}

extension Task {
    convenience init(_ task: Task) {
        self.init()
        // Don't copy _id
        title = task.title
        taskDescription = task.taskDescription
        startDate = task.startDate
        completedDate = task.completedDate
        cancelDate = task.cancelDate
        for renewal in task.renewals {
            renewals.append(Renewal(renewal))
        }
        deadlineDate = task.deadlineDate
        donateOnFailure = task.donateOnFailure
        charities.append(objectsIn: task.charities)
        tags.append(objectsIn: task.tags)
    }
}

extension Task: Samplable {
    static var samples: [Task] { [sample, sample2, sample3] }
    static var sample: Task {
        Task(
            _id: ObjectId("task1-id"),
            title: "Task 1",
            taskDescription: "First task",
            startDate: Date(),
            cancelDate: nil,
            renewals: Renewal.samples,
            deadlineDate: Date().addingTimeInterval(86400),
            donateOnFailure: true,
            charities: [ObjectId("save-the-cats-id")],
            tags: ["animals"])
    }
    static var sample2: Task {
        Task(
            _id: ObjectId("task2-id"),
            title: "Task 2",
            taskDescription: "Second task",
            startDate: Date(),
            cancelDate: nil,
            renewals: Renewal.samples,
            deadlineDate: Date().addingTimeInterval(226400),
            donateOnFailure: false,
            charities: [ObjectId("save-the-bats-id")],
            tags: ["animals", "creepy"])
    }
    static var sample3: Task {
        Task(
            _id: ObjectId("task3-id"),
            title: "Task 3 - with a longer task name than some others",
            taskDescription: "Third task - which has a longer description than some others. Filler text here. Filler text here. ",
            startDate: Date().addingTimeInterval(-86400),
            cancelDate: Date(),
            renewals: [],
            deadlineDate: Date().addingTimeInterval(126400),
            donateOnFailure: false,
            charities: [ObjectId("save-the-tabs")],
            tags: ["developers"])
    }
}
