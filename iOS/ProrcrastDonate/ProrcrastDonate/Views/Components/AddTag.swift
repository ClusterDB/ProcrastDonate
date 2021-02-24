//
//  AddTag.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI

struct AddTag: View {
    var add: () -> Void = {}
       
    var body: some View {
        HStack {
            Button(action: add) {
                Image(systemName: "plus.app.fill")
                    .padding(2)
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                    
            }
        }
        .background(Color.secondary)
        .clipShape(Capsule())
    }
}

struct AddTag_Previews: PreviewProvider {
    static var previews: some View {
        AddTag()
    }
}
