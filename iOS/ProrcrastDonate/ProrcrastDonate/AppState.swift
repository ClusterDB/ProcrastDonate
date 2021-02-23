//
//  AppState.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var localMode = true
    var testUsers = [User]()
    var testTasks = [Task]()
    var testCharities = [Charity]()
    
    func bootstrap(clearOldData: Bool = true) {
        if clearOldData {
            testUsers = []
            testTasks = []
            testCharities = []
        }
        testUsers.append(contentsOf: User.samples)
        testTasks.append(contentsOf: Task.samples)
        testCharities.append(contentsOf: Charity.samples)
    }
}
