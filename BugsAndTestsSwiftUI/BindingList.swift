import SwiftUI



struct BindingListView: View {
    @State private var listStr = ["Un","Deux","Trois","Quatre","Cinq"]
    @State private var listInt = [1,2,3,4,5]
    @State private var listStr2 = [StringInStruct("Un"),StringInStruct("Deux"),StringInStruct("Trois"),StringInStruct("Quatre"),StringInStruct("Cinq")]
    @State private var listStr3 = [StringInStruct("Un"),StringInStruct("Deux"),StringInStruct("Trois"),StringInStruct("Quatre"),StringInStruct("Cinq")]
    
    @State private var listStr4 = ArrayInStruct("Un", "Deux", "Trois")

    // Nécessaire pour éviter les animations bizarres quand on boucle sur .indices
  
    var body: some View {
        List {
            Text("Swipe a row -> Delete -> Boom!")
            
            
            Section(header: Text("Tableau de String (Crash)")) {
                ForEach(listStr.indices, id: \.self) { index in
                    HStack {
                        Text(listStr[index])
                        
                        // CRASH si l'utilisateur supprime un des éléments de la liste :
                        TextField("", text: $listStr[index])
                            .foregroundColor(Color.gray)
                        
                        
                        // TextEditor provoque un CRASH aussi :
                        //TextEditor(text: $listStr[index])
                        
                        // SOLUTION 1 :
                        // Fonctionne ! (plus de crash)
                        // Problème : le Swipe -> Delete produit une animation "bizarre"
                        // Pourquoi ? Car dans le ForEach l'identifiant = l'index, et les index changent lors de la suppression
                        // Voilà :
                        
                        /*TextField("", text: Binding<String>(
                                    get: {listStr[index]}, set: {listStr[index] = $0}
                        ))
                         */
                        
                    }
                }
                .onDelete(perform: { indexSet in
                    listStr.remove(atOffsets: indexSet)
                })
            }
            
            Section(header: Text("Tableau de Int (Crash)")) {
                ForEach(0..<listInt.count, id: \.self) { index in
                    HStack {
                        Text(listInt[index].description)
                            .padding(.trailing, 20)
                        
                        // CRASH si on swipe -> delete :
                        HomeMadeStepper(val: $listInt[index])
                        // Ce n'est donc pas un problème lié au TextField, mais bien au Binding
                        
                        
                        // Ceci étant, le Stepper, lui, ne provoque PAS de crash lors d'une suppression !
                        // Le TextField entraîne un crash, pas le Stepper : ??
                        //Stepper("", value: $listInt[index])
                        
                        
                        // SOLUTION 1.bis :
                        // Binder le tableau, plutôt que l'élément dans le tableau peut régler certains cas
                        // Ici on aura toujours une drôle d'animation au Swipe to delete, liée au ForEach
                        //HomeMadeStepper2(list: $listInt, index: index)
                        //
                    }
                    
                }.onDelete(perform: { indexSet in
                    listInt.remove(atOffsets: indexSet)
                })
            }
            
            
            // SOLUTION 2
            // On inclue notre String dans une struct StringInStruct
            // On peut maintenant associer un id unique (UUID) aux éléments du tableau
            // Et ainsi régler le problème de l'animation "bizarre" !! (l'identifiant est désormais différent de l'index)
            // Bémols : 1) pour Binder, on est obligé de rechercher l'index de chaque élément à partir de son UUID (avec firstIndex(where:))
            // 2) ça ne règle pas intégralement le pb des crashes...
            Section(header: Text("Solution un peu tordue")) {
                ForEach(listStr2) { element in
                    HStack {
                        // 1) la méthode index(in:) renvoie l'index de l'élément
                        Text("\(element.index(in: listStr2))")
                        Text(element.value)
                        
                        // 2) Suppression possible, animation ok. Mais...crashe quand on supprime la dernière ligne ! :
                        TextField("", text: $listStr2[element.index(in: listStr2)].value)
                            .foregroundColor(.gray)
                        
                        // Donc obligé encore de faire ça :
                        /*TextField("", text: Binding<String>(
                                    get: {
                                        listStr2[str.index(in: listStr2)].value
                                        
                                    }, set: {
                                        listStr2[str.index(in: listStr2)].value = $0
                                    })
                        )
                         */
                    }
                }
                .onDelete(perform: { indexSet in
                    listStr2.remove(atOffsets: indexSet)
                })
            }
            
            // SOLUTION 2 Bis
            // On utilise encore une struct StringInStruct, toujours pour dissocier l'index, la valeur, et l'identifiant
            // Seule la manière de boucler change :
            // on procède avec une variante d' enumerated()
            // On évite ainsi les animations "bizarres" : l'identifiant ne sera pas \.0 (l'index)
            //  mais \.1.id (l'UUID)
            // On évite cette fois de faire des firstIndex(where:)
            // On a toujours le crash quand on supprime la dernière ligne, qui implique de traiter ce cas...
            
            Section(header: Text("Solution la meilleure ?")) {
                ForEach(Array(zip(listStr3.indices, listStr3)), id: \.1.id) { index, element in
                    HStack {
                        Text("\(index)")
                        Text(element.value)
                        
                        // Crashe quand on supprime la dernière ligne :
                        //TextField("", text: $listStr3[index].value)
                        
                        // Donc obligé de faire ça :
                        if index < listStr3.count - 1 {
                            TextField("", text: $listStr3[index].value)
                                .foregroundColor(.gray)

                        } else {
                            TextField("", text: Binding<String>(
                                        get: {
                                            listStr3[index].value
                                        }, set: {
                                            listStr3[index].value = $0
                                        })
                            )
                            .foregroundColor(.gray)

                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    listStr3.remove(atOffsets: indexSet)
                    
                })
            }
            
            
        }
    }
}
struct HomeMadeStepper: View {
    @Binding var val: Int
    var body: some View {
        HStack {
            Button("-") {
                val -= 1
            }
            .foregroundColor(Color.green)

            Button("+") {
                val += 1
            }
            .foregroundColor(Color.red)
        }.buttonStyle(PlainButtonStyle())
    }
}
struct HomeMadeStepper2: View {
    @Binding var list: [Int]
    var index: Int
    
    var body: some View {
        HStack {
            Button("-") {
                list[index] -= 1
            }
            .foregroundColor(Color.pink)
            Button("+") {
                list[index] += 1
            }
            .foregroundColor(Color.blue)
        }.buttonStyle(PlainButtonStyle())
    }
}

struct StringInStruct: Identifiable {
    let id = UUID()
    var value: String
    init(_ value: String) {
        self.value = value
    }
    func index(in array: [StringInStruct]) -> Int {
        array.firstIndex(where: {$0.id == id}) ?? 0
    }
}

struct ArrayInStruct {
    var list: [StringInStruct]
    init(_ strs: String...) {
        list = []
        for str in strs {
            list.append(StringInStruct(str))
        }
    }
}

struct BindingListView_Previews: PreviewProvider {
    static var previews: some View {
        BindingListView()
    }
}


// SINON :

//extension Binding where Value: MutableCollection
//{
//  subscript(safe index: Value.Index) -> Binding<Value.Element>
//  {
//    // Get the value of the element when we first create the binding
//    // Thus we have a 'placeholder-value' if `get` is called when the index no longer exists
//    let safety = wrappedValue[index]
//    return Binding<Value.Element>(
//      get: {
//        guard self.wrappedValue.indices.contains(index)
//          else { return safety } //If this index no longer exists, return a dummy value
//        return self.wrappedValue[index]
//    },
//      set: { newValue in
//        guard self.wrappedValue.indices.contains(index)
//          else { return } //If this index no longer exists, do nothing
//        self.wrappedValue[index] = newValue
//    })
//  }
//}
