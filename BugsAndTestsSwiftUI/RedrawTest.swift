//
//  RedrawTest.swift
//  MyProduct
//
//  Created by Admin on 14/12/2020.
//
import Combine
import SwiftUI

struct Modification {
    var modif1: Bool = false
    var modif2: Bool = false

}
class Modif: ObservableObject {
    @Published var modif1: Bool = false
    @Published var modif2: Bool = false
    @Published var modif3: Modification = Modification()
}

struct RedrawTest: View {
    @State private var modif: Bool = false
    @ObservedObject private var modifObject = Modif()
    @ObservedObject var appStore: AppStore = AppStore(initialState: AppState(), reducer: Reducer.appReducer())
    
    var body: some View {
        print("reload")
        return VStack {
            Print(modif.description)
//            Print(modifObject.modif2.description)
//            Print(modifObject.modif3.modif2.description)

//            Print(appStore.state.modif.description)
            //
            //Print("lil", b: modif)
            ScrollView {
                ForEach(1...1000, id: \.self) {_ in
                    if !appStore.state.searchResult.isEmpty {
                        Text(appStore.state.searchResult[0])
                    }
                    Print("lol", b: appStore.state.modif2)
                }
            }
            //Text(modif.description)
            Button {
                //modif.toggle()
                //modifObject.modif1.toggle()
//                modifObject.modif3.modif1.toggle()
//                modifObject.modif3 = Modification(modif1: false, modif2: false)
                appStore.send(.search(query: ""))
            } label: {
                Text("click")
            }
        }
    }
}


struct Print: View {
    @EnvironmentObject var modif: Modif
    var b: Bool
    var a: String
    var text: String {
        //print(a)
        return ""
    }
    init(_ a: String, b: Bool = true) {
        self.a = a
        self.b = b
    }
    var body: some View {
        print(a)
        return Text(text)
    }
}

struct RedrawTest_Previews: PreviewProvider {
    static var previews: some View {
        RedrawTest()
    }
}


struct AppState {
    var searchResult: [String] = []
    var modif: Bool = false
    var modif2: Bool = false

}

enum AppAction {
    case search(query: String)
    case setSearchResults(repos: String)
    case toggle
}

//typealias Reducer<State, Action> = (inout State, Action) -> Void

struct Reducer<State, Action> {
    typealias Change = (inout State) -> Void
    let reduce: (State, Action) -> AnyPublisher<Change, Never>
    
}

extension Reducer where State == AppState, Action == AppAction {
    static func sync(_ fun: @escaping (inout State) -> Void) -> AnyPublisher<Change, Never> {
            Just(fun).eraseToAnyPublisher()
    }
    
    static func appReducer() -> Reducer {
        return Reducer {state, action in
            switch action {
            case let .setSearchResults(repos):
                return Reducer.sync {state in
                    state.modif.toggle()
                }
            case let .search(query):
                return AnimalService()
                        .generateAnimalInTheFuture()
                        .subscribe(on: DispatchQueue.main)
                        .map {string in
                            {state in state.searchResult.append(string)}
                            
                        }
                    
                        .eraseToAnyPublisher()
                
            case .toggle:
                return Reducer.sync {state in
                    state.modif.toggle()
                }
            }
            return Empty().eraseToAnyPublisher()
        }
    }
    
    
}




final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var cancellables: Set<AnyCancellable> = []
    init(initialState: State, reducer: Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
            reducer
                .reduce(state, action)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: perform)
                .store(in: &cancellables)
        }

    private func perform(change: (inout State) -> Void) {
        change(&state)
    }
}
typealias AppStore = Store<AppState, AppAction>


struct AnimalService {

    func generateAnimalInTheFuture() -> AnyPublisher<String, Never> {
        let animals = ["Cat", "Dog", "Crow", "Horse", "Iguana", "Cow", "Racoon"]
        let number = Double.random(in: 0..<5)
        return Future<String, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + number) {
                let result = animals.randomElement() ?? ""
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }

}
