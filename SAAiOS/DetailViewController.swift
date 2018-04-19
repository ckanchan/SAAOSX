//
//  DetailViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import OraccJSONtoSwift

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textControl: UISegmentedControl!
    
    
    var detailItem: OraccCatalogEntry? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var textStrings: TextEditionStringContainer? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        textControl?.selectedSegmentIndex = 2
        textView?.attributedText = textStrings?.normalisation
        
        navigationItem.title = detailItem?.title
    }
    
    override func viewDidLoad() {
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeText(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            textView.text = textStrings?.cuneiform
        case 1:
            textView.attributedText = textStrings?.transliteration
        case 2:
            textView.attributedText = textStrings?.normalisation
        default:
            textView.text = textStrings?.translation
        }
    }
    
    
    
    


}

