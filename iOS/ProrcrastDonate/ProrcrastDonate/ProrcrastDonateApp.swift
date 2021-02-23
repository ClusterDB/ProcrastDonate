//
//  ProrcrastDonateApp.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

@main
struct ProrcrastDonateApp: App {
    @StateObject var state = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
        }
    }
}
