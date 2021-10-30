//
//  BindingViewModels.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 31/08/2021.
//

import Combine
import SwiftUI

struct ListView: View {
    @StateObject var vm = ListViewModel()
    var body: some View {
        NavigationView {
            List(Array(vm.data.enumerated()), id: \.1.id) { index, item in
                NavigationLink(destination: DetailView(vm: DetailViewModel(item: item, saveWith: vm.archivist, at: index
                ))) {
                    Text(item.name)
                }
            }
        }
    }
}

struct DetailView: View {
    @ObservedObject var vm: DetailViewModel

    var body: some View {
        VStack {
            TextField("name", text: $vm.item.name)
            TextField("description", text: $vm.item.description)
            Button("save") {
                vm.save()
            }
        }
    }
}

struct Item: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    static var fakeItems: [Item] = [.init(name: "My item", description: "Very good"), .init(name: "An other item", description: "not so bad")]
}

protocol UpdateManager {
    func update(_ item: Item, at index: Int)
}

class ListViewModel: ObservableObject {
    @Published var data: [Item]
    var archivist = PassthroughSubject<(Int, Item), Never>()
    var cancellable: AnyCancellable?
    init(items: [Item] = Item.fakeItems) {
        data = items
        cancellable = archivist
            .sink {[weak self ]index, item in
                self?.update(item, at: index)
            }
    }
    func update(_ item: Item, at index: Int) {
        data[index] = item
    }
}

class DetailViewModel: ObservableObject {
    @Published var item: Item
    var index: Int
    var archivist: PassthroughSubject<(Int, Item), Never>
    init(item: Item, saveWith archivist: PassthroughSubject<(Int, Item), Never>, at index: Int) {
        self.item = item
        self.archivist = archivist
        self.index = index
    }
    func fetch() {}
    func save() {
        archivist.send((index, item))
    }
}

struct BindingViewModels_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

// class ListViewModel2: ObservableObject {
//    @Published var data: [DetailViewModel]
//    var bag: Set<AnyCancellable> = []
//
//    init(items: [Item] = Item.fakeItems) {
//        data = items.map(DetailViewModel.init(item:))
//        subscribeToItemsChanges()
//    }
//    func subscribeToItemsChanges() {
//        data.enumerated().publisher
//            .flatMap { (index, detailVM) in
//                detailVM.$initialItem
//                    .map{ (index, $0 )}
//            }
//            .sink { [weak self] index, newValue in
//                self?.data[index].item = newValue
//                self?.objectWillChange.send()
//            }
//            .store(in: &bag)
//    }
// }
