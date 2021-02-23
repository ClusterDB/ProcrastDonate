//
//  Renewal.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import Foundation
import RealmSwift

@objcMembers class Renewal: EmbeddedObject, ObjectKeyIdentifiable {
    dynamic var date = Date()
    dynamic var oldDeadline = Date()
    dynamic var newDeadline = Date().addingTimeInterval(86400)
    dynamic var oldAmount: Double = 0
    dynamic var newAmount: Double = 0
    dynamic var renewReason = ""
    dynamic var paidOldAmount = false

    convenience init(
        date: Date,
        oldDeadline: Date,
        newDeadline: Date,
        oldAmount: Double,
        newAmount: Double,
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
}
