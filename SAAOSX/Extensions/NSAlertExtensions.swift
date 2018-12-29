//
//  NSAlertExtensions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 29/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

extension NSAlert {
    static func createWarning(messageText: String, informativeText: String, button1Text: String, button2Text: String) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: button1Text)
        alert.addButton(withTitle: button2Text)
        alert.alertStyle = .warning
        return alert
    }
}

