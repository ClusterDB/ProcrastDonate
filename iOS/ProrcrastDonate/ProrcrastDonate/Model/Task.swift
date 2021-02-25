//
//  Task.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import SwiftBSON

class Task: ObservableObject, Identifiable, Codable {
    @Published var _id: BSONObjectID
    @Published var title: String
    @Published var user: BSONObjectID
    @Published var descriptionText: String
    @Published var startDate: Date
    @Published var completedDate: Date?
    @Published var cancelDate: Date?
    @Published var renewals: [Renewal]
    @Published var deadlineDate: Date
    @Published var donateOnFailure: Bool
    @Published var donationAmount: Donation?
    @Published var charity: BSONObjectID?
    @Published var tags: [String]
    
    var id: String { _id.description }
    var completed: Bool { completedDate != nil }

    init() {
        _id = BSONObjectID()
        title = ""
        user  = BSONObjectID()
        descriptionText = ""
        startDate = Date()
        renewals = [Renewal]()
        deadlineDate = Date().addingTimeInterval(86400)
        donateOnFailure = false
        tags = [String]()
    }
    
    convenience init(
        _id: BSONObjectID = BSONObjectID(),
        title: String,
        user: BSONObjectID,
        descriptionText: String,
        startDate: Date = Date(),
        completedDate: Date? = nil,
        cancelDate: Date? = nil,
        renewals: [Renewal] = [],
        deadlineDate: Date,
        donateOnFailure: Bool,
        donationAmount: Donation? = nil,
        charity: BSONObjectID? = nil,
        tags: [String]
    ) {
        self.init()
        self._id = _id
        self.title = title
        self.user = user
        self.descriptionText = descriptionText
        self.startDate = startDate
        self.completedDate = completedDate
        self.cancelDate = cancelDate
        self.renewals.append(contentsOf: renewals)
        self.deadlineDate = deadlineDate
        self.donateOnFailure = donateOnFailure
        self.donationAmount = donationAmount
        self.charity = charity
        self.tags.append(contentsOf: tags)
    }
    
    enum CodingKeys: CodingKey {
//        case _id
        case title
        case user
        case descriptionText
        case startDate
        case completedDate
        case cancelDate
//        case renewals
        case deadlineDate
        case donateOnFailure
        case donationAmount
        case charity
        case tags
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        _id = try container.decode(BSONObjectID.self, forKey: ._id)
        _id = BSONObjectID()
        title = try container.decode(String.self, forKey: .title)
        user = try container.decode(BSONObjectID.self, forKey: .user)
        descriptionText = try container.decode(String.self, forKey: .descriptionText)
        startDate = try container.decode(Date.self, forKey: .startDate)
        completedDate = try container.decodeIfPresent(Date.self, forKey: .completedDate)
        cancelDate = try container.decodeIfPresent(Date.self, forKey: .cancelDate)
//        renewals = try container.decodeIfPresent([Renewal].self, forKey: .renewals)
        renewals = []
        deadlineDate = try container.decode(Date.self, forKey: .deadlineDate)
        donateOnFailure = try container.decode(Bool.self, forKey: .donateOnFailure)
        donationAmount = try container.decodeIfPresent(Donation.self, forKey: .donationAmount)
        charity = try container.decodeIfPresent(BSONObjectID.self, forKey: .charity)
        tags = try container.decode([String].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(_id, forKey: ._id)
        try container.encode(title, forKey: .title)
        try container.encode(user, forKey: .user)
        try container.encode(descriptionText, forKey: .descriptionText)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(completedDate, forKey: .completedDate)
        try container.encodeIfPresent(cancelDate, forKey: .cancelDate)
//        try container.encode(renewals, forKey: .renewals)
        try container.encode(deadlineDate, forKey: .deadlineDate)
        try container.encode(donateOnFailure, forKey: .donateOnFailure)
        try container.encodeIfPresent(donationAmount, forKey: .donationAmount)
        try container.encodeIfPresent(charity, forKey: .charity)
        try container.encode(tags, forKey: .tags)
    }
}
