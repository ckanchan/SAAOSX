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
    var textInfo: OraccCatalogEntry
    var body: some View {
        List {
            Section(header: Text("Basic Information")) {
                Text(textInfo.title)
                Text(textInfo.chapter)
                textInfo.ancientAuthor.map({Text($0)})
            }
            Section(header: Text("Text IDs")) {
                Text(textInfo.id.description)
                Text(textInfo.displayName)
                textInfo.museumNumber.map({Text($0)})
            }
            Section(header: Text("Archaeological Data")) {
                textInfo.genre.map({Text($0)})
                textInfo.material.map({Text($0)})
                textInfo.period.map({Text($0)})
                textInfo.provenience.map({Text($0)})
            }
            Section(header: Text("Publication Data")) {
                textInfo.primaryPublication.map({Text($0)})
                textInfo.publicationHistory.map({Text($0).lineLimit(nil)})
                textInfo.notes.map({Text($0)})
            }
            Section(header: Text("Credits")) {
                textInfo.credits.map({Text($0).lineLimit(nil)})
            }
        }.listStyle(.grouped)
    }
}

#if DEBUG
struct TextInfoView_Previews : PreviewProvider {
    static var previews: some View {
        TextInfoView(textInfo: SQLiteCatalogue()!.getEntryFor(id: "P224485")!)
    }
}
#endif
