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

struct ContentView : View {
    var sqlite: SQLiteCatalogue
    var body: some View {
        NavigationView {
            List(sqlite.texts) { textEntry in
                NavigationButton(destination: TextDetail(strings: self.sqlite.getTextStrings(textEntry.id)!,
                                                         metadata: textEntry)){
                    ListRow(textItem: textEntry)
                }
                }.navigationBarTitle(Text("SAAi"))
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(sqlite: SQLiteCatalogue()!)
    }
}
#endif
