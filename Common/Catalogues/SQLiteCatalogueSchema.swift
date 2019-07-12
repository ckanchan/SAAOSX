//
//  SQLiteCatalogueSchema.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 04/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import CDKSwiftOracc
import Foundation
import os
import SQLite

extension SQLiteCatalogue {
    enum Schema {
        static let textid = Expression<String>("textid")
        static let project = Expression<String>("project")
        static let displayName = Expression<String>("display_name")
        static let title = Expression<String>("title")
        static let ancientAuthor = Expression<String?>("ancient_author")
        
        // Additional catalogue data
        static let chapterNumber = Expression<Int?>("chapter_num")
        static let chapterName = Expression<String?>("chapter_name")
        static let museumNumber = Expression<String?>("museum_num")
        
        // Archaeological data
        static let genre = Expression<String?>("genre")
        static let material = Expression<String?>("material")
        static let period = Expression<String?>("period")
        static let provenience = Expression<String?>("provenience")
        
        //Publication data
        static let primaryPublication = Expression<String?>("primary_publication")
        static let publicationHistory = Expression<String?>("publication_history")
        static let notes = Expression<String?>("notes")
        static let credits = Expression<String?>("credits")
        
        //Location data
        static let pleiadesID = Expression<Int?>("pleiades_id")
        static let pleiadesCoordinateX = Expression<Double?>("pleiades_coordinate_x")
        static let pleiadesCoordinateY = Expression<Double?>("pleiades_coordinate_y")
        
        // A place to encode TextEditionStringContainer with NSCoding
        static let textStrings = Expression<Data>("Text")
        static let textTable = Table("texts")
    }
}

extension SQLiteCatalogue.Schema {
    static func selectAll(withStrings: Bool = false) -> QueryType {
        if withStrings {
            return textTable.select(displayName,
                                    title,
                                    textid,
                                    ancientAuthor,
                                    project,
                                    chapterNumber,
                                    chapterName,
                                    genre,
                                    material,
                                    period,
                                    provenience,
                                    primaryPublication,
                                    museumNumber,
                                    publicationHistory,
                                    notes,
                                    pleiadesID,
                                    pleiadesCoordinateX,
                                    pleiadesCoordinateY,
                                    credits,
                                    textStrings)
        } else {
            return textTable.select(displayName,
                                    title,
                                    textid,
                                    ancientAuthor,
                                    project,
                                    chapterNumber,
                                    chapterName,
                                    genre,
                                    material,
                                    period,
                                    provenience,
                                    primaryPublication,
                                    museumNumber,
                                    publicationHistory,
                                    notes,
                                    pleiadesID,
                                    pleiadesCoordinateX,
                                    pleiadesCoordinateY,
                                    credits)
        }
    }
    
    static func selectTextID() -> QueryType {
        return textTable.select(textStrings)
    }
}
