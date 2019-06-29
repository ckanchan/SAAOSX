//
//  TextInfoView.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 21/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI
import CDKSwiftOracc

struct TextInfoView : View {
    @Environment(\.isPresented) var isPresented: Binding<Bool>?
    
    var textInfo: OraccCatalogEntry
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextInfoViewRow(title: "Title", value: textInfo.title)
                    TextInfoViewRow(title: "Chapter", value: textInfo.chapter)
                    textInfo.ancientAuthor.map({TextInfoViewRow(title: "Chapter", value: $0)})
                }
                Section(header: Text("Text IDs")) {
                    TextInfoViewRow(title: "CDLI ID", value: textInfo.id.description)
                    TextInfoViewRow(title: "Designation", value: textInfo.displayName)
                    textInfo.museumNumber.map({TextInfoViewRow(title: "Museum Number", value: $0)})
                }
                Section(header: Text("Archaeological Data")) {
                    textInfo.genre.map({TextInfoViewRow(title: "Genre", value: $0)})
                    textInfo.material.map({TextInfoViewRow(title: "Material", value: $0)})
                    textInfo.period.map({TextInfoViewRow(title: "Period", value: $0)})
                    textInfo.provenience.map({TextInfoViewRow(title: "Provenience", value: $0)})
                }
                Section(header: Text("Publication Data")) {
                    textInfo.primaryPublication.map({TextInfoViewRow(title: "Primary publication", value: $0)})
                    textInfo.publicationHistory.map({TextInfoViewRow(title: "Publication history", value: $0)})
                    textInfo.notes.map({TextInfoViewRow(title: "Notes", value: $0)})
                }
                Section(header: Text("Credits")) {
                    textInfo.credits.map({Text($0).lineLimit(nil)})
                }
            }
            
//            Button(action: {self.isPresented?.value = false}) {
//                Text("Dismiss")
//            }
        }
    }
}

struct TextInfoViewRow: View {
    var title: String
    var value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline).color(.secondary)
            Text(value).lineLimit(nil)
        }
    }
}

#if DEBUG
struct TextInfoView_Previews : PreviewProvider {
    static var previews: some View {
        TextInfoView(textInfo: SQLiteCatalogue()!.getEntryFor(id: "P224485")!)
    }
}
#endif
