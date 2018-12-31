//
//  FBDBController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc


protocol TextNoteDisplaying: AnyObject {
    func noteDidChange(_ note: Note)
}

protocol SingleAnnotationDisplaying: AnyObject {
    func annotationDidChange(_ annotation: Note.Annotation)
}
