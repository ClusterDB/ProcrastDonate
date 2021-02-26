//
//  Renewal.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

class Renewal: ObservableObject, Identifiable, Codable {
    @Published var id = UUID().uuidString
    @Published var date = Date()
    @Published var oldDeadline = Date()
    @Published var newDeadline = Date().addingTimeInterval(86400)
    @Published var oldAmount = 0
    @Published var newAmount = 0
    @Published var renewReason = ""
    @Published var paidOldAmount = false
    
    init() {}
    
    convenience init(
        date: Date,
        oldDeadline: Date,
        newDeadline: Date,
        oldAmount: Int,
        newAmount: Int,
        renewReason: String,
        paidOldAmount: Bool
    ) {
        self.init()
        self.date = date
        self.oldDeadline = oldDeadline
        self.newDeadline = newDeadline
        self.oldAmount = oldAmount
        self.newAmount = newAmount
        self.renewReason = renewReason
        self.paidOldAmount = paidOldAmount
    }
    
    enum CodingKeys: CodingKey {
        case id
        case date
        case oldDeadline
        case currency
        case newDeadline
        case oldAmount
        case newAmount
        case renewReason
        case paidOldAmount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        oldDeadline = try container.decode(Date.self, forKey: .oldDeadline)
        newDeadline = try container.decode(Date.self, forKey: .newDeadline)
        oldAmount = try container.decode(Int.self, forKey: .oldAmount)
        newAmount = try container.decode(Int.self, forKey: .newAmount)
        renewReason = try container.decode(String.self, forKey: .renewReason)
        paidOldAmount = try container.decode(Bool.self, forKey: .paidOldAmount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(oldDeadline, forKey: .oldDeadline)
        try container.encode(newDeadline, forKey: .newDeadline)
        try container.encode(oldAmount, forKey: .oldAmount)
        try container.encode(newAmount, forKey: .newAmount)
        try container.encode(renewReason, forKey: .renewReason)
        try container.encode(paidOldAmount, forKey: .paidOldAmount)
    }
}
