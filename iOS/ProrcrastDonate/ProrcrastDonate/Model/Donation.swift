//
//  Donation.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 25/02/2021.
//

import Foundation

class Donation: ObservableObject, Codable {
    @Published var amount = 0
    @Published var currency = "USD"
    
    init() {}

    convenience init(amount: Int, currency: String = "USD") {
        self.init()
        self.amount = amount
        self.currency = currency
    }
    
    enum CodingKeys: CodingKey {
        case amount
        case currency
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
    }
}
