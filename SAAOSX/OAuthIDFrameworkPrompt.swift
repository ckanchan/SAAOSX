//
//  OAuthIDFrameworkPrompt.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class OAuthIDFrameworkPrompt: NSViewController {
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var clientID: NSTextField!
    @IBOutlet weak var clientSecret: NSSecureTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let infoURL = Bundle.main.url(forResource: "OAuthInfo", withExtension: "rtf") else {return}
        guard let rtfData = try? Data(contentsOf: infoURL) else {return}
        guard let infoStr = NSAttributedString(rtf: rtfData, documentAttributes: nil) else {return}
        infoLabel.attributedStringValue = infoStr
    }
    
    @IBAction func save(_ sender: Any) {
        defer {
            NSApplication.shared.abortModal()
            view.window?.close()
        }
        
        let id = self.clientID.stringValue
        let secret = self.clientSecret.stringValue
        
        let credential = GoogleOAuthCredentials(clientID: id, clientSecret: secret)
        
        do {
            try credential.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
