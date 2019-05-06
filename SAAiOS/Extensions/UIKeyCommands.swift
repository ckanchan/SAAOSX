//
//  UIKeyCommands.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 08/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

// Dispatches all available key commands to the text view controller
extension UISplitViewController {
    @objc func handleKeyCommand(_ keyCommand: UIKeyCommand) {
        if let detailNavigationController = self.viewControllers.last as? UINavigationController {
            if let textEditionController = detailNavigationController.visibleViewController as? TextEditionViewController {
                textEditionController.handleKeyCommand(keyCommand)
            }
        }
    }

    var leftKeyCommand: UIKeyCommand {
        return UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Previous Text")
    }

    var rightKeyCommand: UIKeyCommand {
        return UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Next Text")
    }

    var cuneiformLeft: UIKeyCommand {
        return UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show cuneiform in primary column")
    }

    var transliterationLeft: UIKeyCommand {
        return UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show transliteration in primary column")
    }

    var normalisationLeft: UIKeyCommand {
        return UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show normalisation in primary column")
    }

    var translationLeft: UIKeyCommand {
        return UIKeyCommand(input: "4", modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show translation in primary column")
    }

    var cuneiformRight: UIKeyCommand {
        return UIKeyCommand(input: "1", modifierFlags: .alternate, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show cuneiform in secondary column")
    }

    var transliterationRight: UIKeyCommand {
        return UIKeyCommand(input: "2", modifierFlags: .alternate, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show transliteration in secondary column")
    }

    var normalisationRight: UIKeyCommand {
        return UIKeyCommand(input: "3", modifierFlags: .alternate, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show normalisation in secondary column")
    }

    var translationRight: UIKeyCommand {
        return UIKeyCommand(input: "4", modifierFlags: .alternate, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show translation in secondary column")
    }
    
    var infoSidebarKey: UIKeyCommand {
        return UIKeyCommand(input: "I", modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Show info")
    }

    override open var keyCommands: [UIKeyCommand]? {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return [leftKeyCommand, rightKeyCommand, cuneiformLeft, transliterationLeft, normalisationLeft, translationLeft, cuneiformRight, transliterationRight, normalisationRight, translationRight, infoSidebarKey]
        default:
            return [leftKeyCommand, rightKeyCommand, cuneiformLeft, transliterationLeft, normalisationLeft, translationLeft, infoSidebarKey]

        }
    }

}

@objc protocol KeyCommandHandler: AnyObject {
    func handleKeyCommand(_ keyCommand: UIKeyCommand)
}

// Receives key commands in this method
extension TextEditionViewController: KeyCommandHandler {
    @objc func handleKeyCommand(_ keyCommand: UIKeyCommand) {
        guard let input = keyCommand.input else {return}

        if "1234".contains(input) {
            guard let inputValue = Int(input) else {return}
            guard let newTextDisplay = TextDisplay.init(rawValue: inputValue - 1) else {return}

            switch keyCommand.modifierFlags {
                
                //Switch the left panel to the new txt display
            case .command:
                self.primaryPanel.changeText(display: newTextDisplay, scrollToTop: false)

            case .alternate:
                guard let secondaryPanel = self.secondaryPanel else {return}
                secondaryPanel.changeText(display: newTextDisplay, scrollToTop: false)

            default:
                return
            }
        }

        switch keyCommand.modifierFlags {
        case .command:
            switch input {
            case UIKeyCommand.inputLeftArrow:
                self.navigate(keyCommand)
            case UIKeyCommand.inputRightArrow:
                self.navigate(keyCommand)
            case "I":
                self.presentInformation()
            default:
                return
            }
        default:
            return
        }

    }
}
