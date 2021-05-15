//
//  UPCItemTest.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 12/05/2021.
//

import SwiftUI
import Combine
struct UPCItemTest: View {
    @State private var item: UPCItem?
    @State private var cancellables: Set<AnyCancellable> = []
    var body: some View {
        VStack {
            if let item = item {
                Text(item.title)
            }
            Button("Fetch") {
                APISession().fetch(request: Endpoint<UPCItemRequest?>.fetchItem(upc: "885909950805"))
                    .replaceError(with: nil)
                    .sink { value in
                        self.item = value?.item
                    }
                    .store(in: &cancellables)
            }
        }
    }
}

struct UPCItemTest_Previews: PreviewProvider {
    static var previews: some View {
        UPCItemTest()
    }
}
