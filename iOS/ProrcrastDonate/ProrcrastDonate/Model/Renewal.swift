//
//  Renewal.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

class Renewal: ObservableObject, Identifiable {
    let id  = UUID().uuidString
    @Published var date = Date()
    @Published var oldDeadline = Date()
    @Published var newDeadline = Date().addingTimeInterval(86400)
    @Published var oldAmount: Double = 0
    @Published var newAmount: Double = 0
    @Published var renewReason = ""
    @Published var paidOldAmount = false
    
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
