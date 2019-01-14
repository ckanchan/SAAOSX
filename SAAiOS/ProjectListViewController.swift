//
//  MasterViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

enum Navigate {
    case left, right
}

class ProjectListViewController: UITableViewController {

    var detailViewController: TextEditionViewController?
    var filteredTexts: [OraccCatalogEntry] = []
    lazy var catalogue: CatalogueProvider = {return sqlite}()


    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search texts"
        searchController.searchBar.addShortcuts()
        navigationItem.searchController = searchController
        definesPresentationContext = true

        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.reloadData()
        
        if self.catalogue.source != .search {
            let glossaryButton = UIBarButtonItem(title: "Glossary", style: .plain, target: self, action: #selector(showGlossary))
            self.setToolbarItems([glossaryButton], animated: false)
        } else {
            self.title = catalogue.name
        }
        
        
        let preferencesButton = UIBarButtonItem(title: "⚙︎", style: .plain, target: self, action: #selector(loadPreferences))
        
        navigationItem.rightBarButtonItem = preferencesButton
    }
    
    @objc func loadPreferences() {
        guard let preferencesViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.PreferencesViewController) else {return}
        navigationController?.pushViewController(preferencesViewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc func showGlossary(_ sender: Any?) {
        guard let glossaryController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.Glossary) as? GlossaryTableViewController else {return}

        if let quickDefinition = sender as? UIBarButtonItem {
            if let text = quickDefinition.title {
                if text != "Glossary" {
                let cf = text.prefix(while: {$0 != ":"})
                if !cf.isEmpty {
                    glossaryController.searchController.isActive = true
                    glossaryController.searchController.searchBar.text = String(cf)
                    glossaryController.searchController.searchBar.selectedScopeButtonIndex = 0
                    glossaryController.updateSearchResults(for: glossaryController.searchController)

                    }
                }
            }
        }

        self.navigationController?.pushViewController(glossaryController, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (catalogueEntry, textStrings) = getTextViewData(for: indexPath) else {return}
        
        let controller = TextEditionViewController()
        
        controller.textItem = catalogueEntry
        controller.textStrings = textStrings
        controller.catalogue = self.catalogue
        controller.parentController = self
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        
        if catalogue.source == .search {
            guard let catalogue = self.catalogue as? Catalogue,
                let textSearch = catalogue.catalogue as? TextSearchCollection else {return}
            let searchTerm = textSearch.searchTerm
            controller.searchTerm = searchTerm
        }
        
        let navigationController = UINavigationController(rootViewController: controller)

        
        self.showDetailViewController(navigationController, sender: self)
        self.appDelegate.didChooseDetail = true
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
    }
    

    func getTextViewData(for indexPath: IndexPath) -> (OraccCatalogEntry, TextEditionStringContainer)? {
        let catalogueEntry: OraccCatalogEntry
        if isFiltering() {
            catalogueEntry = filteredTexts[indexPath.row]
        } else {
            catalogueEntry = catalogue.texts[indexPath.row]
        }

        guard let textStrings = sqlite.getTextStrings(catalogueEntry.id) else {return nil}

        return (catalogueEntry, textStrings)

    }

    func getIndexPath(_ direction: Navigate) -> IndexPath? {
        guard let selection = tableView.indexPathForSelectedRow else {return nil}
        switch direction {
        case .left:
            return IndexPath(row: selection.row - 1, section: selection.section)

        case .right:
            return IndexPath(row: selection.row + 1, section: selection.section)
        }
    }

    func navigate(_ direction: Navigate) {
        guard let newIndexPath = getIndexPath(direction) else {return}
        guard tableView.cellForRow(at: newIndexPath) != nil else {return}

        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .middle)
    }
}

// MARK: - Table view methods
extension ProjectListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTexts.count
        } else {
            return catalogue.texts.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let textItem: OraccCatalogEntry

        if isFiltering() {
            textItem = filteredTexts[indexPath.row]
        } else {
            textItem = catalogue.texts[indexPath.row]
        }

        cell.textLabel?.text = textItem.displayName
        cell.detailTextLabel?.text = textItem.title
        return cell
    }
}

// MARK: - Search Controller methods
extension ProjectListViewController: UISearchResultsUpdating {
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTexts = catalogue.texts.filter {
            $0.description.lowercased().contains(searchText.lowercased()
            )}
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


extension ProjectListViewController {
    static func new(detailViewController: TextEditionViewController?) -> ProjectListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: UIViewController.StoryboardIDs.ProjectListViewController) as! ProjectListViewController
        vc.detailViewController = detailViewController
        return vc
    }
}
