//
//  TextBox.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 22/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SwiftUI

struct TextBox: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Binding var selectedDisplayMode: Int
    
    var textStrings: [String]
    
    
    var body: some View {
        return GeometryReader { geometry in
            ScrollView {
                    Text(self.textStrings[self.selectedDisplayMode])        
                        .lineLimit(nil)
                        .padding()
                        .frame(maxWidth:geometry.size.width,
                               idealHeight: 2000,
                               alignment: .topLeading)
                }
        }.frame(alignment: .topLeading)
    }
}

#if DEBUG
struct TextBox_Previews : PreviewProvider {
    static var previews: some View {
        let catalogue = SQLiteCatalogue()!
        let strings = catalogue.getTextStrings("P224485")!.rawStrings
        return TextBox(selectedDisplayMode: .constant(2), textStrings: strings)
    }
}
#endif
