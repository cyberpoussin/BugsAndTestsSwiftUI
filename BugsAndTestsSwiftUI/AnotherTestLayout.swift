//
//  AnotherTestLayout.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 10/06/2021.
//

import SwiftUI

struct AnotherTestLayout: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(users) {user in
                    HStack {
                        Text(user.rank.description)
                        Text(user.name)
                            .lineLimit(1)
                        Text(user.steps.description)
                        Text(user.trees.description)
                    }
                }
            }
        }
    }
}

struct AnotherTestLayout_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnotherTestLayout()
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            AnotherTestLayout()
                .previewDevice("iPhone 8")
        }
    }
}
