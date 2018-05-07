//
//  GlossaryTableViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 07/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

class GlossaryTableViewController: UITableViewController {
    var filteredGlossary: [(Int, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseSearchControllers()
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !searchBarIsEmpty() {
            return filteredGlossary.count
        }
        
        return glossary.glossaryCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let citationForm: String
        let guideWord: String
        
        if !searchBarIsEmpty() {
            let (_, cf, gw) = filteredGlossary[indexPath.row]
            citationForm = cf
            guideWord = gw
        } else {
            guard let (cf, gw) = glossary.labelsForRow(row: indexPath.row + 1) else {
                return cell
            }
            citationForm = cf
            guideWord = gw
            
        }
        
        cell.textLabel?.text = citationForm
        cell.detailTextLabel?.text = guideWord
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row: Int
        
        if !searchBarIsEmpty() {
            (row, _, _) = filteredGlossary[indexPath.row]
        } else {
            row = indexPath.row + 1
        }
        
        guard let glossaryEntry = glossary.entryForRow(row: row) else {return}
        guard let xisReferences = glossary.getXISReferences(glossaryEntry.headWord) else {return}
        let searchSet = sqlite.getSearchCollection(term: glossaryEntry.citationForm, references: xisReferences)
        
        let sortedSet = searchSet.members.values.sorted(by: {$0.displayName < $1.displayName})
        
        let searchSetViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.ProjectLIstViewController) as! ProjectListViewController
        
        let catalogue = Catalogue.init(catalogue: searchSet, sorted: sortedSet, source: .search)
        
        searchSetViewController.catalogue = catalogue
        searchSetViewController.tableView.reloadData()
        
        navigationController?.pushViewController(searchSetViewController, animated: true)
        
    }
    
    // MARK: - Search controller configuration
    let searchController = UISearchController(searchResultsController: nil)
    func initialiseSearchControllers() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search glossary"
        searchController.searchBar.addShortcuts()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredGlossary = glossary.searchDatabase(searchText.lowercased())
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension GlossaryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
