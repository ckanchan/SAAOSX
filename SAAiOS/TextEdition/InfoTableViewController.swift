//
//  InfoTableViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 07/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

class InfoTableViewController: UITableViewController {
    var catalogueInfo: OraccCatalogEntry!
    weak var textEditionViewController: TextEditionViewController?
    
    static let sectionTitles = ["Basic Information",
                         "Text IDs",
                         "Archaeological Data",
                         "Publication Data",
                         "Credits",
                         "Options"
                         ]
    
    static let basicInformation = ["Text Title",
                            "Chapter",
                            "Ancient Author",
                            ]
    
    static let textIDs = ["CDLI ID",
                   "Designation",
                   "Museum Number",
                   ]
    
    static let archeologicalData = ["Genre",
                             "Material",
                             "Period",
                             "Provenience",
                             ]

    static let publicationData = ["Primary publication",
                           "Publication history",
                           "Notes",
                           ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return InfoTableViewController.sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return InfoTableViewController.basicInformation.count
        case 1:
            return InfoTableViewController.textIDs.count
        case 2:
            return InfoTableViewController.archeologicalData.count
        case 3:
            return InfoTableViewController.publicationData.count
        case 4:
            return 1
        case 5:
            return 2
        default:
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return InfoTableViewController.sectionTitles[section] }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = nil
        cell.textLabel?.textColor = UIColor.darkText
        cell.detailTextLabel?.text = nil
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            //Basic info
            cell.populateBasicInfo(for: catalogueInfo, at: indexPath)
        case 1:
            //Text IDs
            cell.populateTextIDs(for: catalogueInfo, at: indexPath)
        case 2:
            //archaeologicalData
            cell.populateArchaeologicalData(for: catalogueInfo, at: indexPath)
        case 3:
            //publication data
            cell.populatePublicationData(for: catalogueInfo, at: indexPath)
        case 4:
            //credits data
            cell.textLabel?.text = catalogueInfo.credits ?? ""
            cell.textLabel?.numberOfLines = 0


        case 5:
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = "View on Oracc"
                cell.detailTextLabel?.textColor = UIColor.blue
                cell.selectionStyle = .default
            } else {
                cell.detailTextLabel?.text = "Dismiss"
                cell.detailTextLabel?.textColor = UIColor.blue
                cell.selectionStyle = .default
            }
            
        default:
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presentingVC = self.textEditionViewController else {return}
        
        switch indexPath.section {
        case 5:
            if indexPath.row == 0 {
                presentingVC.viewOnline()
                presentingVC.dismiss(animated: true)
            } else if indexPath.row == 1 {
                presentingVC.dismiss(animated: true)
            }
        default:
            return
        }
    }
}



extension UITableViewCell {
    func populateBasicInfo(for catalogueInfo: OraccCatalogEntry, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.textLabel?.text = InfoTableViewController.basicInformation[0]
            self.detailTextLabel?.text = catalogueInfo.title
        case 1:
            self.textLabel?.text = InfoTableViewController.basicInformation[1]
            self.detailTextLabel?.text = catalogueInfo.chapter
        case 2:
            self.textLabel?.text = InfoTableViewController.basicInformation[2]
            self.detailTextLabel?.text = catalogueInfo.ancientAuthor ?? "No author assigned"
        default:
            return
        }
    }
    
    func populateTextIDs(for catalogueInfo: OraccCatalogEntry, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.textLabel?.text = InfoTableViewController.textIDs[0]
            self.detailTextLabel?.text = catalogueInfo.id
        case 1:
            self.textLabel?.text = InfoTableViewController.textIDs[1]
            self.detailTextLabel?.text = catalogueInfo.displayName
        case 2:
            self.textLabel?.text = InfoTableViewController.textIDs[2]
            self.detailTextLabel?.text = catalogueInfo.museumNumber ?? "No museum number available"
        default:
            return
        }
    }
    
    func populateArchaeologicalData(for catalogueInfo: OraccCatalogEntry, at indexPath: IndexPath){
        switch indexPath.row {
        case 0:
            self.textLabel?.text = InfoTableViewController.archeologicalData[0]
            self.detailTextLabel?.text = catalogueInfo.genre ?? "No genre assigned"
        case 1:
            self.textLabel?.text = InfoTableViewController.archeologicalData[1]
            self.detailTextLabel?.text = catalogueInfo.material ?? "No data"
        case 2:
            self.textLabel?.text = InfoTableViewController.archeologicalData[2]
            self.detailTextLabel?.text = catalogueInfo.period ?? "No period assigned"
        case 3:
            self.textLabel?.text = InfoTableViewController.archeologicalData[3]
            self.detailTextLabel?.text = catalogueInfo.provenience ?? "No provenience assigned"
        default:
            return
        }
    }
    
    func populatePublicationData(for catalogueInfo: OraccCatalogEntry, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.textLabel?.text = InfoTableViewController.publicationData[0]
            self.detailTextLabel?.text = catalogueInfo.primaryPublication ?? "Primary publication not available"
        case 1:
            self.textLabel?.text = InfoTableViewController.publicationData[1]
            self.detailTextLabel?.text = catalogueInfo.publicationHistory ?? "No publication history available"
        case 2:
            self.textLabel?.text = InfoTableViewController.publicationData[2]
            self.detailTextLabel?.text = catalogueInfo.notes ?? "None"
        default:
            return
        }
    }
}
