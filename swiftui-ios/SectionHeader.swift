//
//  SectionHeader.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 29/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import SwiftUI

struct SectionHeader : View {
    var project: SAAVolume
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: project.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 80, maxHeight: 100)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.top)
                .padding(.bottom)
            VStack(alignment: .leading){
                Text(project.title).font(.headline)
                Text(project.blurb)
                    .font(.caption)
                    .lineLimit(nil)
            }
        }
    }
}

#if DEBUG
struct SectionHeader_Previews : PreviewProvider {
    static var previews: some View {
        List {
            Section(header: SectionHeader(project: .saa01)) {
                Text("Entry")
            }
        }
    }
}
#endif
