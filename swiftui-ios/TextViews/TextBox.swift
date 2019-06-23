//
//  TextBox.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 22/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import SwiftUI

struct TextBox: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Binding var selectedDisplayMode: Int
    
    var textStrings: TextEditionStringContainer
    
    
    var body: some View {
        let text: Text
        switch selectedDisplayMode {
        case 0: text = Text(textStrings.cuneiform).font(.custom("CuneiformNAOutline-Medium", size: 20))
        case 1: text = textStrings.transliteration.renderForSwiftUI()
        case 2: text = textStrings.normalisation.renderForSwiftUI()
        case 3: text = Text(textStrings.translation)
        default: text = Text("Not available").font(.subheadline)
        }
    
        return GeometryReader { geometry in
            ScrollView {
                text
                    .lineLimit(nil)
                    .padding()
                    .frame(maxWidth:geometry.size.width,
                           alignment: .topLeading)
                }.frame(alignment: .topLeading)
        }
    }
}

#if DEBUG
struct TextBox_Previews : PreviewProvider {
    static var previews: some View {
        let catalogue = SQLiteCatalogue()!
        let strings = catalogue.getTextStrings("P224485")!
        return
            Group {
                TextBox(selectedDisplayMode: .constant(0), textStrings: strings).previewDisplayName("Cuneiform")
                TextBox(selectedDisplayMode: .constant(1), textStrings: strings).previewDisplayName("Transliteration")
                TextBox(selectedDisplayMode: .constant(2), textStrings: strings).previewDisplayName("Normalisation")
                TextBox(selectedDisplayMode: .constant(3), textStrings: strings).previewDisplayName("Translation")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
