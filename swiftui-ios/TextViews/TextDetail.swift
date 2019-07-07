//
//  TextDetail.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 17/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI
import CDKSwiftOracc

struct TextDetail : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var strings: TextEditionStringContainer {
        return sqlite.getTextStrings(metadata.id)!
    }
    
    var metadata: OraccCatalogEntry
    var sqlite: SQLiteCatalogue
    var body: some View {
        
        Group {
            if horizontalSizeClass == .regular {
                HStack {
                    TextColumn(strings: strings)
                    TextColumn(strings: strings)
                    }
            } else {
                TextColumn(strings: strings)
            }
            }.navigationBarTitle(Text(metadata.title),
                                 displayMode: .inline)
            .navigationBarItems(trailing: NavigationButtons(textInfo: metadata))
    }
}

#if DEBUG
struct TextDetail_Previews : PreviewProvider {
    static var previews: some View {
        let catalogue = SQLiteCatalogue()!
        let metadata = catalogue.getEntryFor(id: "P224485")!
        let textView = TextDetail(metadata: metadata, sqlite: catalogue)
        
        return NavigationView {textView}
    }
}
#endif

struct NavigationButtons: View {
    var textInfo: OraccCatalogEntry
    var body: some View {
        HStack {
            WebViewButton(textInfo: self.textInfo)
            TextInfoButton(textInfo: self.textInfo)
        }
    }
}

struct TextInfoButton: View {
    var textInfo: OraccCatalogEntry
    var body: some View {
        PresentationLink(destination: TextInfoView(textInfo: self.textInfo), label: {Image(systemName: "info.circle")})
    }
}

struct WebViewButton: View {
    var textInfo: OraccCatalogEntry
    var body: some View {
        PresentationLink(destination: WebView(address: self.textInfo.url), label: {Image(systemName: "safari")})
    }
}

extension OraccCatalogEntry {
    var url: URL {
        URL(string: "http://oracc.org/\(self.id)/\(self.project)/html")!
    }
}
