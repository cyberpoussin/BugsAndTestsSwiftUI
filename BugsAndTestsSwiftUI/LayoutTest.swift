//
//  LayoutTest.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 10/06/2021.
//

import SwiftUI

struct UserCedric: Identifiable {
    let id = UUID()
    var name: String
    var rank: Int
    var steps: Int
    var trees: Int
}

let users: [UserCedric] = [.init(name: "JP", rank: 1, steps: 3, trees: 5), .init(name: "Jean de la Villardière de la Motte", rank: 2, steps: 4, trees: 23), .init(name: "Cédric de Bernardin", rank: 3, steps: 2, trees: 3)]


struct LayoutTest: View {
    func getColumns(totalWidth: CGFloat) -> [GridItem] {
        return [
            GridItem(.fixed(totalWidth*0.10)),
            GridItem(.flexible()),
            GridItem(.fixed(totalWidth*0.10)),
            GridItem(.fixed(totalWidth*0.10)),
        ]
    }
    
    var body: some View {
        
        GeometryReader {geo in
            ScrollView {
            LazyVGrid(columns: getColumns(totalWidth: geo.size.width), alignment: .leading) {
                ForEach(users){user in
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

struct LayoutTest_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LayoutTest()
            LayoutTest()
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
        }
    }
}
