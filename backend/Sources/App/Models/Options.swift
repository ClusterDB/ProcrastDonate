struct MonetaryValue: Codable {
    enum Currency: String, Codable {
        case USD = "USD"
    }

    /// 1/100th units of the given currency. e.g. 1 cent in USD
    let amount: UInt

    /// The type of currency
    let currency: Currency
}
