//
//  MenuTest.swift
//  NewProjectApril
//
//  Created by admin on 03/05/2021.
//

import SwiftUI

struct MenuTest: View {
    let elements: Set<String> = ["lol", "lil", "loul", "karl"]
    @State private var checkedElements: Set<String> = []

    var body: some View {
        HStack {
            Color.green
            VStack {
                MultipleSelectionPicker(elements: elements, checkedElements: $checkedElements, buttonColor: Color.red) {
                    Color.purple
                        .frame(width: 200, height: 400)
                }
                Spacer()
            }
        }
        
    }
}

struct MultipleSelectionPicker<Content: View>: View {
    init(elements: Set<String>, checkedElements: Binding<Set<String>>, buttonColor: Color = .blue, content: @escaping () -> Content) {
        self.elements = elements
        _checkedEls = State(initialValue: checkedElements.wrappedValue)
        self._checkedElements = checkedElements
        self.content = content
        self.buttonColor = buttonColor
    }
    
    @State private var selected = false
    var elements: Set<String> = []
    var elementsArray: Array<String> {
        Array(elements).sorted(by: { $0 < $1 })
    }

    var maxHeight: CGFloat = 800
    @State private var height: CGFloat? = nil
    @State private var contentHeight: CGFloat? = nil
    @State private var contentWidth: CGFloat? = nil

    @State private var checkedEls: Set<String> = []

    @Binding var checkedElements: Set<String>
    var heightLine: CGFloat { height ?? 1 }
    var scrollable: Bool {
        (CGFloat(elements.count) * heightLine) > maxHeight
    }

    var buttonColor: Color = Color.blue

    var content: () -> Content
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            content()
                .overlay(
                    Text(height?.description ?? "rien")
                )
                .syncingHeight($contentHeight)
                .syncingWidth($contentWidth)
                .onTapGesture {
                    withAnimation(.linear(duration: 0.3)) {
                        checkedEls = checkedElements
                        selected.toggle()
                    }
                }
                .zIndex(12)
            if selected {
                VStack(spacing: 0) {
                    GeometryReader { _ in
                        ScrollView {
                            Color.red
                                .frame(width: contentWidth, height: contentHeight)
                            Divider()
                                // .frame(height:1)
                                .padding(.top, 2)
                            // Rectangle()
                            // .frame(height:1)
                            VStack(spacing: 0) {
                                ForEach(elementsArray, id: \.self) { element in
                                    SelectionRow(text: element, alreadyCheck: checkedEls.contains(element)) {
                                        if checkedEls.contains(element) {
                                            checkedEls.remove(element)
                                        } else {
                                            checkedEls.insert(element)
                                        }
                                    }
                                    .syncingHeight($height)
                                }
                                Spacer()
                            }
                            Button {
                                withAnimation(.linear(duration: 0.3)) {
                                    checkedElements = checkedEls
                                    selected.toggle()
                                }
                            } label: {
                                Capsule()
                                    .fill(buttonColor)
                                    .frame(height: 25)
                                    .padding(.horizontal, 10)
                                    .overlay(Text("VALIDER")
                                    .foregroundColor(.white))
                                    .padding(.top, 5)
                            }

                            Spacer()
                        }
                        .frame(height: scrollable ? maxHeight : CGFloat(elements.count) * heightLine + (contentHeight ?? 0) + 70)
                        .frame(width: (contentWidth ?? 10) - 10)
                        .padding(.bottom, 10)

                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)

                        // .padding(.bottom, -(CGFloat(CGFloat(elements.count) * (height ?? 20))))
                        .onChange(of: height, perform: { _ in
                            UIScrollView.appearance().bounces = scrollable

                        })
                    }
                    
                }
                // .transition(AnyTransition.move(edge: .top))
                .zIndex(11)
            }
        }
        .frame(width: (contentWidth ?? 10) - 10)
    }
}

struct SelectionRow: View {
    var text: String
    var isSelected: () -> Void
    @State private var checked: Bool = false
    init(text: String, alreadyCheck: Bool, isSelected: @escaping() -> ()) {
        self.isSelected = isSelected
        self.text = text
        _checked = State(initialValue: alreadyCheck)
    }
    var body: some View {
        HStack {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.blue)
                .padding(5)
                .padding(.leading, 15)
            // Spacer()
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .padding(.trailing, 10)
                .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
                .onTapGesture {
                    isSelected()

                    self.checked.toggle()
                }
        }
    }
}

extension View {
//

    func syncingHeight(_ height: Binding<CGFloat?>) -> some View {
        overlay(GeometryReader { proxy in
            // We have to attach our preference assignment to
            // some form of view, so we just use a clear color
            // here to make that view completely transparent:
            Color.clear.preference(
                key: HeightPreferenceKey.self,
                value: proxy.size.height
            )
        })
            .onPreferenceChange(HeightPreferenceKey.self) {
                height.wrappedValue = $0
                print("Hauteur : \($0)")
            }
    }

    func syncingWidth(_ width: Binding<CGFloat?>) -> some View {
        overlay(GeometryReader { proxy in
            // We have to attach our preference assignment to
            // some form of view, so we just use a clear color
            // here to make that view completely transparent:
            Color.clear.preference(
                key: WidthPreferenceKey.self,
                value: proxy.size.width
            )
        })
            .onPreferenceChange(WidthPreferenceKey.self) {
                width.wrappedValue = $0
                print("Largeur : \($0)")
            }
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat,
                       nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct WidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat,
                       nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CheckBoxView: View {
    @Binding var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}

struct MenuTest_Previews: PreviewProvider {
    static var previews: some View {
        MenuTest()
    }
}
