//
//  InfoSideBarViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 18/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class InfoSideBarViewController: NSViewController {

    @IBOutlet weak var textTitle: NSTextField!
    @IBOutlet weak var chapterTitle: NSTextField!
    @IBOutlet weak var ancientAuthor: NSTextField!
    @IBOutlet weak var textIDs: NSTextField!
    
    @IBOutlet weak var archData: NSTextField!
    
    @IBOutlet weak var pubData: NSTextField!
    @IBOutlet weak var Credits: NSTextField!
    
    func setLabels(_ selectedText: OraccCatalogEntry){
        textTitle.stringValue = selectedText.title
        if let chapterNumber = selectedText.chapterNumber {
            chapterTitle.stringValue = "Chapter \(chapterNumber): \(selectedText.chapterName?.trimmingCharacters(in: CharacterSet(charactersIn: "()")) ?? "no chapter assigned")"
        }
        
        ancientAuthor.stringValue = selectedText.ancientAuthor ?? "No author assigned"
        textIDs.stringValue = {
            var str = ""
            str.append("CDLI ID: \(selectedText.id)\t")
            str.append("Designation: \(selectedText.displayName)\t")
        
            
            if let museumNumber = selectedText.museumNumber {
                str.append("Museum number: \(museumNumber)")
            }
            return str
        }()
        
        archData.stringValue = {
            var str = ""
            if let genre = selectedText.genre {
                str.append("Genre: \(genre)\t")
            }
            
            if let material = selectedText.material {
                str.append("Material: \(material)\t")
            }
            
            if let period = selectedText.period {
                str.append("Period: \(period)\t")
            }
            
            if let provenience = selectedText.provenience {
                str.append("Provenience: \(provenience)")
            }
            
            return str
        }()
        
        pubData.stringValue = {
            var str = ""
            
            if let primaryPublication = selectedText.primaryPublication {
                str.append("Primary publication: \(primaryPublication)\t")
            }
            
            if let history = selectedText.publicationHistory {
                str.append("Publication history: \(history)")
            }
            
            if let notes = selectedText.notes {
                str.append("Notes: \(notes)")
            }
            
            
            return str
        }()
        
        Credits.stringValue = selectedText.credits ?? ""
    }
    
}
