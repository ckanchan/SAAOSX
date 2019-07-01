//
//  ContentView.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 17/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI
import CDKSwiftOracc

extension OraccCatalogEntry: Identifiable {}

struct TextListView: View {
    var sqlite: SQLiteCatalogue
    var texts: [SAAVolume: [OraccCatalogEntry]] {
        var t = [SAAVolume: [OraccCatalogEntry]]()
        for volume in SAAVolume.allVolumes {
            t[volume] = sqlite.entriesForVolume(volume)
        }
        return t
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(texts.keys.sorted().identified(by: \.self)) { key in
                    Section(header: SectionHeader(project: key) ) {
                        ForEach(self.texts[key]!) { textEntry in
                            NavigationButton(destination: TextDetail( metadata: textEntry, sqlite: self.sqlite)){
                                                                        ListRow(textItem: textEntry)
                            }
                        }
                    }
                    
                }
                }.navigationBarTitle(Text("SAAi"))
        }
    }
}

#if DEBUG
struct TextListView_Previews : PreviewProvider {
    static var previews: some View {
        TextListView(sqlite: SQLiteCatalogue()!)
    }
}
#endif
