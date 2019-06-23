//
//  ListRow.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 17/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import CDKSwiftOracc
import SwiftUI

struct ListRow: View {
    var textItem: OraccCatalogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(textItem.title)
            HStack(spacing: 20) {
                Text(textItem.displayName)
                    .font(.subheadline)
                Divider()
                Text(textItem.id.description)
                    .font(.subheadline)
                    .color(.secondary)
            }
        }
    }
}

#if DEBUG
struct ListRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ListRow(textItem: PreviewData.Texts[0])
            .previewDisplayName("Light")
            
            ListRow(textItem: PreviewData.Texts[1])
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark")
        }
            .previewLayout(.sizeThatFits)
    }
}
#endif
