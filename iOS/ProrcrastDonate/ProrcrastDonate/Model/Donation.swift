//
//  Donation.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 25/02/2021.
//

import Foundation

class Donation: ObservableObject {
    @Published var amount = 0
    @Published var currency = "USD"

    convenience init(
        amount: Int,
        currency: String = "USD"
    ) {
        self.init()
        self.amount = amount
        self.currency = currency
    }
}
