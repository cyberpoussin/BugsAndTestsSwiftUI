//
//  ProtocolTestView.swift
//  MyProduct
//
//  Created by Admin on 19/01/2021.
//

import SwiftUI
import Foundation


protocol Fighter: Equatable {
    var name: String { get }
}

struct XWing: Fighter {
    var name: String = "xwing"
    var blaster: String = "lol"
}

struct YWing: Fighter {
    var name = "ywing"
}

protocol Squadron {
    associatedtype FighterInSquadron: Fighter
    var items: [FighterInSquadron] { get }
}

struct GenericSquadron<T: Fighter>: Squadron {
    var items: [T]
}

struct GenericFighter<T: Fighter>: Fighter {
    var element: T
    var name: String
    init(element: T) {
        self.element = element
        name = element.name
    }
}

func launchFighter<T: Fighter>(fighter: T) -> some Fighter {
    return GenericFighter(element: fighter)
}

func createSquadron<T: Fighter>(list: [T]) -> some Squadron {
    return GenericSquadron(items: list)
}


protocol ListItemDisplayable {
  var name: String { get }
}

struct Shoe: ListItemDisplayable {
  let name: String
}


protocol ListDataSource {
  associatedtype ListItem: ListItemDisplayable

  var items: [ListItem] { get }
  var numberOfItems: Int { get }
  func itemAt(_ index: Int) -> ListItem
}

struct ShoesDataSource: ListDataSource {
  let items: [Shoe]
  var numberOfItems: Int { items.count }

  func itemAt(_ index: Int) -> Shoe {
    return items[index]
  }
}

struct ViewModelGenerator {
    func listProvider<T: ListItemDisplayable>(for items: [T]) -> some ListDataSource {
        if let items = items as? [Shoe] {
            return ShoesDataSource(items: items)
        }
        // hmmm
        return ShoesDataSource(items: [])
  }
}
func makeInt() -> some Equatable {
    Int.random(in: 1...10)
}
var int1: some Equatable = makeInt()

var lol: some ListDataSource = ViewModelGenerator().listProvider(for: [Shoe(name: "adidas")])

var lol2 = GenericFighter(element: XWing())
var lol3: some Fighter = launchFighter(fighter: XWing())

var fighter: some Fighter = launchFighter(fighter: YWing())

struct ProtocolTestView: View {
    var body: some View {
        Text("\(lol.numberOfItems)")
    }
}

struct ProtocolTestView_Previews: PreviewProvider {
    static var previews: some View {
        ProtocolTestView()
    }
}
