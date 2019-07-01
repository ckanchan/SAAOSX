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
                textItem.ancientAuthor.map {
                    Text($0)
                }
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
            ListRow(textItem: SQLiteCatalogue()!.getEntryFor(id: "P224485")!)
            .previewDisplayName("Light")
            
            ListRow(textItem: SQLiteCatalogue()!.getEntryFor(id: "P224485")!)
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark")
        }
            .previewLayout(.fixed(width: 800, height: 48))
    }
}
#endif
