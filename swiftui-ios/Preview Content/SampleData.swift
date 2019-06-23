//
//  SampleData.swift
//  swiftui-ios
//
//  Created by Chaitanya Kanchan on 17/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

enum PreviewData {
    static let Texts: [OraccCatalogEntry] = [
        OraccCatalogEntry(id: "P000000",
                          displayName: "SMP 001",
                          ancientAuthor: nil,
                          title: "Sample Text 1",
                          project: "Sample Project"),
        OraccCatalogEntry(id: "P000001",
                          displayName: "SMP 002",
                          ancientAuthor: nil,
                          title: "Sample Text 2",
                          project: "Sample Project")
            
    ]
}
