//
//  AskAtheloView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 27/06/2022.
//

import SwiftUI

struct AskAtheloView: View {
    @ObservedObject private(set) var model: AskAtheloModel
    let sendMessageAction: () -> Void
    let onURLTapAction: (URL) -> Void
    
    @State private var selectedObjectModel = ExpandableEntrySelectionModel()

    private var entriesBinding: Binding<[ExpandableEntryData]> {
        Binding(
            get: { model.entries },
            set: { model.updateEntries($0) }
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 24.0) {
                    StyledText("Frequently Asked Questions",
                               textStyle: .intro,
                               colorStyle: .purple623E61)
                    .padding([.bottom], 16.0)
                    
                    ForEach(entriesBinding) { $entry in
                        ExpandableEntryView(entry: entry, geometry: geometry, additionalOffset: 16.0 * 2.0, onURLTapAction: onURLTapAction)
                            .transition(.opacity)
                    }
                    .zIndex(10)
                    
                    VStack(spacing: 16.0) {
                        StyledText("faq.morequestions".localized(),
                                   textStyle: .link,
                                   colorStyle: .gray)
                        
                        StyledButtonView(title: "action.sendmessage".localized()) {
                            sendMessageAction()
                        }
                        .frame(height: 52.0, alignment: .center)
                    }
                }
                .padding([.top, .bottom], 24.0)
                .padding([.leading, .trailing], 16.0)
            }
        }
        .animation(.default)
        .background(Rectangle().fill(.clear), alignment: .center)
        .environmentObject(selectedObjectModel)
    }
}

struct AskAtheloView_Previews: PreviewProvider {
    private static let model = AskAtheloModel(entries: ExpandableEntryData.samples())
    
    static var previews: some View {
        VStack {
            Button {
                model.addEntry(ExpandableEntryData.random())
            } label: {
                Text("Add item")
            }
            
            AskAtheloView(model: model,
                          sendMessageAction: { /* ... */ },
                          onURLTapAction: { _ in /* ... */ })
        }
    }
}

private extension ExpandableEntryData {
    static func random() -> ExpandableEntryData {
        ExpandableEntryData(title: UUID().uuidString, content: UUID().uuidString)
    }
    
    static func samples() -> [ExpandableEntryData] {
        [
            ExpandableEntryData(title: "How about some Lorem Ipsum with longer title?", content: "Donec rutrum tellus lectus, eget tristique nisi consequat non. Phasellus convallis malesuada tortor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut eget dapibus odio. Class aptent taciti sociosqu ad litora torquent per conubia nostra, <i>per inceptos himenaeos.</i> Praesent imperdiet tellus at enim accumsan, ac laoreet erat pellentesque. Fusce in accumsan urna. Curabitur aliquet magna vel nunc aliquam, ut mattis metus viverra. Proin id nulla ligula. Aliquam condimentum <u>efficitur dui</u>, ac scelerisque augue facilisis in. Nam orci mauris, rhoncus sed venenatis id, sagittis nec mi. Fusce ac risus ipsum. Aliquam rhoncus dolor sit amet odio tincidunt, eu pellentesque quam tincidunt. Vivamus cursus pharetra tortor sit amet pharetra."),
            ExpandableEntryData(title: "<p>Title</p>", content: "Content."),
            ExpandableEntryData(title: "A longer title", content: "A longer content that will span a bit, I guess."),
            ExpandableEntryData(title: "<p>An extraordinarily longer title, just to make things a little bit spicier. Everybody <b>loves spices</b>, at least a spice, at least they like like, or is indifferent to it. But does anybody hate all spices? I doubt it.</p>", content: "<p>A bit longer content, but not too much than the previous one.</p><p>And another paragraph!</p><ul><li>A</li><li>B</li></ul><p>Nice.</p><p>Very nice.</p>"),
            ExpandableEntryData(title: "Shorter title", content: "Shorter content."),
            ExpandableEntryData(title: "How about some Lorem Ipsum?", content: "Donec rutrum tellus lectus, eget tristique nisi consequat non. Phasellus convallis malesuada tortor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut eget dapibus odio. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent imperdiet tellus at enim accumsan, ac laoreet erat pellentesque. Fusce in accumsan urna. Curabitur aliquet magna vel nunc aliquam, ut mattis metus viverra. Proin id nulla ligula. Aliquam condimentum efficitur dui, ac scelerisque augue facilisis in. Nam orci mauris, rhoncus sed venenatis id, sagittis nec mi. Fusce ac risus ipsum. Aliquam rhoncus dolor sit amet odio tincidunt, eu pellentesque quam tincidunt. Vivamus cursus pharetra tortor sit amet pharetra.")
        ]
    }
}

