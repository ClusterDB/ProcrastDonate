//
//  ContentView.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TaskListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
