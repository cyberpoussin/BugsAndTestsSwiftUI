//
//  RedrawTest2.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 10/06/2021.
//

import SwiftUI

class GLobalStore: ObservableObject {
    @Published var changed: Bool = false
}

struct MainTest: View {
    @StateObject var environmentStore = GLobalStore()
    @StateObject var observedStore = GLobalStore()
    var body: some View {
        VStack {
            Button("Change l'observedStore !") { observedStore.changed.toggle() }
            Button("Change l'environmentStore !") { environmentStore.changed.toggle() }
            RedrawTest1(observedStore: observedStore)
                .environmentObject(environmentStore)
        }
    }
}

struct RedrawTest1: View {
    @ObservedObject var observedStore: GLobalStore

    var body: some View {
        print("moi aussi j'ai changé, je le jure")

        return RedrawTest2(observedStore: observedStore)
    }
}

struct RedrawTest2: View {
    @EnvironmentObject var environmentStore: GLobalStore
    @ObservedObject var observedStore: GLobalStore
    var body: some View {
        print("j'ai changé, je le jure")
        return Text("Hello, World!")
    }
}

//struct RedrawTest2_Previews: PreviewProvider {
//    static var previews: some View {
//        RedrawTest2(observedStore: GLobalStore())
//    }
//}
