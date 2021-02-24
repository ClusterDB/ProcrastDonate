//
//  Date.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import Foundation

extension Date {
    static func getPrintStringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func fullDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d yyyy h:mm a"
        return formatter.string(from: self)
    }

    func justDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func justDateInYear() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func justLongDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func justTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma z"
        return formatter.string(from: self)
    }
}
