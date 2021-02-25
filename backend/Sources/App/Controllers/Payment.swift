import Vapor
// TODO: make this a real payment processor

enum Payment {
    static func processDonation(
        _ req: Request,
        to charity: Charity,
        by user: User,
        amount donation: MonetaryValue
    ) -> EventLoopFuture<Void> {
        req.logger.info("\(user.username) successfully donated $\(donation.amount / 100) to \"\(charity.name)\"")
        return req.eventLoop.makeSucceededFuture(())
    }
}
