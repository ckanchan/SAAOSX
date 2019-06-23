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
    
    var strings: TextEditionStringContainer
    var metadata: OraccCatalogEntry
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
            .navigationBarItems(trailing: TextInfoButton(textInfo: self.metadata))
    }
}

#if DEBUG
struct TextDetail_Previews : PreviewProvider {
    static var previews: some View {
        let catalogue = SQLiteCatalogue()!
        let strings = catalogue.getTextStrings("P224485")!
        let metadata = catalogue.getEntryFor(id: "P224485")!
        let textView = TextDetail(strings: strings,
                                  metadata: metadata)
        
        return NavigationView {textView}
    }
}
#endif

struct TextInfoButton: View {
    var textInfo: OraccCatalogEntry
    var body: some View {
        PresentationButton(destination: TextInfoView(textInfo: textInfo), label: {Image(systemName: "info.circle")})
    }
}

