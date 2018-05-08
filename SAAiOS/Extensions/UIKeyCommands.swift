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
        return UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Previous Text")
    }
    
    var rightKeyCommand: UIKeyCommand {
        return UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .command, action: #selector(self.handleKeyCommand(_:)), discoverabilityTitle: "Next Text")
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
    
    
    
    override open var keyCommands: [UIKeyCommand]? {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return [leftKeyCommand, rightKeyCommand, cuneiformLeft,transliterationLeft, normalisationLeft, translationLeft, cuneiformRight, transliterationRight, normalisationRight, translationRight]
        default:
            return [leftKeyCommand, rightKeyCommand, cuneiformLeft,transliterationLeft, normalisationLeft, translationLeft]
            
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
            guard let displayState = self.displayState else {return}
            let newDisplayState: DisplayState
            
            switch keyCommand.modifierFlags {
            case .command:
                switch displayState {
                case .single(_):
                    newDisplayState = .single(newTextDisplay)
                case .double(left: _, right: let right):
                    newDisplayState = .double(left: newTextDisplay, right: right)
                }
                
            case .alternate:
                switch displayState {
                case .single(_):
                    return
                case .double(left: let left, right: _):
                    newDisplayState = .double(left: left, right: newTextDisplay)
                }
                
            default:
                return
            }
            
            self.displayState = newDisplayState
        }
        
        switch keyCommand.modifierFlags {
        case .command:
            switch input {
            case UIKeyInputLeftArrow:
                self.navigate(keyCommand)
            case UIKeyInputRightArrow:
                self.navigate(keyCommand)
            default:
                return
            }
            
        default:
            return
        }
        
    }
}

