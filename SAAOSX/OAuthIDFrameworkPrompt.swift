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
        // Do view setup here.
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
