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
        friends.append(contentsOf: user.friends)
    }
}

extension User: Samplable {
    static var samples: [User] { [sample, sample2, sample3] }
    static var sample: User {
        User(
            _id: ObjectId("f0d456789012345678901234"),
            userName: "rod",
            displayName: "Rod",
            email: "rod@contoso.com",
            password: "rainbow",
            bio: "Singer from Rod, Jane and Freddy",
            friends: [sample2._id, sample3._id])
    }
    static var sample2: User {
        User(
            _id: ObjectId("1ade56789012345678901234"),
            userName: "jane",
            displayName: "Jane",
            email: "jane@contoso.com",
            password: "rainbow",
            bio: "The best singer from Rod, Jane and Freddy",
            friends: [sample._id, sample3._id])
    }
    static var sample3: User {
        User(
            _id: ObjectId("ffedde789012345678901234"),
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

extension Charity {
    convenience init (_ charity: Charity) {
        self.init()
        _id = charity._id
        name = charity.name
        description = charity.description
        website = charity.website
    }
}

extension Charity: Samplable {
    static var samples: [Charity] { [sample, sample2, sample3] }
    static var sample: Charity {
        Charity(
            _id: ObjectId("cad456789012345678901234"),
            name: "Save The Cats",
            description: "Looking after the furry little critters",
            website: "https://clusterdb.com")
    }
    static var sample2: Charity {
        Charity(
            _id: ObjectId("bad456789012345678901234"),
            name: "Save The Bats",
            description: "Blocking planning applications for years",
            website: "https://clusterdb.com")
    }
    static var sample3: Charity {
        Charity(
            _id: ObjectId("1ab456789012345678901234"),
            name: "Save The Tabs",
            description: "Spaces are for the birds",
            website: "https://clusterdb.com")
    }
}

extension Task {
    convenience init(_ task: Task) {
        self.init()
        // Don't copy _id
        title = task.title
        description = task.description
        startDate = task.startDate
        completedDate = task.completedDate
        cancelDate = task.cancelDate
        for renewal in task.renewals {
            renewals.append(Renewal(renewal))
        }
        deadlineDate = task.deadlineDate
        donateOnFailure = task.donateOnFailure
        charities.append(contentsOf: task.charities)
        tags.append(contentsOf: task.tags)
    }
}

extension Task: Samplable {
    static var samples: [Task] { [sample, sample2, sample3] }
    static var sample: Task {
        Task(
            _id: ObjectId("111456789012345678901234"),
            title: "Task 1",
            description: "First task",
            startDate: Date(),
            cancelDate: nil,
            renewals: Renewal.samples,
            deadlineDate: Date().addingTimeInterval(86400),
            donateOnFailure: true,
            charities: [Charity.sample._id],
            tags: ["animals"])
    }
    static var sample2: Task {
        Task(
            _id: ObjectId("222456789012345678901234"),
            title: "Task 2",
            description: "Second task",
            startDate: Date(),
            cancelDate: nil,
            renewals: Renewal.samples,
            deadlineDate: Date().addingTimeInterval(226400),
            donateOnFailure: false,
            charities: [Charity.sample2._id],
            tags: ["animals", "creepy"])
    }
    static var sample3: Task {
        Task(
            _id: ObjectId("333456789012345678901234"),
            title: "Task 3 - with a longer task name than some others",
            description: "Third task - which has a longer description than some others. Filler text here. Filler text here. ",
            startDate: Date().addingTimeInterval(-86400),
            cancelDate: Date(),
            renewals: [],
            deadlineDate: Date().addingTimeInterval(126400),
            donateOnFailure: false,
            charities: [Charity.sample._id, Charity.sample3._id],
            tags: ["developers"])
    }
}
