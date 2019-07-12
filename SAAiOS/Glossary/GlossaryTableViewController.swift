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
    lazy var prefetcher: Glossary = {
        return Glossary()
    }()

    var prefetchStore: [IndexPath: (String, String)] = [:]

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search glossary"
        searchController.searchBar.addShortcuts()

        searchController.searchBar.scopeButtonTitles = ["Lemma", "English", "All"]
        searchController.searchBar.selectedScopeButtonIndex = 2

        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }

    override func didReceiveMemoryWarning() {
        prefetchStore.removeAll(keepingCapacity: false)
    }

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
            if let (prefetchedCf, prefetchedGw) = prefetchStore[indexPath] {
                citationForm = prefetchedCf
                guideWord = prefetchedGw
            } else if let (cf, gw) = glossary.labelsForRow(row: indexPath.row + 1) {
                citationForm = cf
                guideWord = gw
            } else {
                return cell
            }
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

        let searchSetViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.ProjectListViewController) as! ProjectListViewController

        let catalogue = Catalogue.init(catalogue: searchSet, sorted: sortedSet, source: .search)

        searchSetViewController.catalogue = catalogue
        searchSetViewController.tableView.reloadData()

        navigationController?.pushViewController(searchSetViewController, animated: true)

    }
}

extension GlossaryTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard !self.isFiltering() else {return} // Prefetching is not needed with a search set

        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            for indexPath in indexPaths {
                guard self.prefetchStore[indexPath] == nil else { return }
                guard let strings = self.prefetcher.labelsForRow(row: indexPath.row) else {return}
                self.prefetchStore.updateValue(strings, forKey: indexPath)
                }
            }
        }
}

// MARK: - Search controller configuration
extension GlossaryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let scope = SearchScope.init(rawValue: searchController.searchBar.selectedScopeButtonIndex)

        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }

    enum SearchScope: Int {
        case Lemma, English, All
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: SearchScope? = nil) {
        let text: String
        if let scope = scope {
            switch scope {
            case .Lemma:
                text = "cf:\(searchText)"
            default:
                text = searchText
            }
        } else {
            text = searchText
        }

        filteredGlossary = glossary.searchDatabase(text.lowercased())
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
