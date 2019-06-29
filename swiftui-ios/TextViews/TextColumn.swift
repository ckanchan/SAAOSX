//
//  TextColumn.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 22/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI

struct TextColumn : View {
    @State private var selectedDisplayMode = 3
    var strings: TextEditionStringContainer
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {

            TextBox(selectedDisplayMode: $selectedDisplayMode, textStrings: strings)
            SegmentedControl(selection: $selectedDisplayMode) {
                ForEach(0..<TextType.allCases.count) { index in
                    Text(TextType.allCases[index].rawValue).tag(index)
                }
            }
        }
    }
}

enum TextType: String, CaseIterable {
    case Cuneiform, Transliteration, Normalisation, Translation
}

#if DEBUG
struct TextColumn_Previews : PreviewProvider {
    static var previews: some View {
        let catalogue = SQLiteCatalogue()!
        let strings = catalogue.getTextStrings("P224485")!
        let view = TextColumn(strings: strings)
        return HStack {
            view
            view
            }.previewDisplayName("iPad Layout").frame(alignment: .topLeading)
            .environment(\.horizontalSizeClass, .regular)
    }
}
#endif
