//
//  MasterViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc
import WebKit

enum Navigate {
    case left, right
}

class ProjectListViewController: UITableViewController {
    var noTextsLoadedPromptShownAlreadyInSession: Bool = false
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
        switch catalogue.source {
        case .search:
            let label = UILabel()
            label.text = catalogue.name
            let labelBtn = UIBarButtonItem(customView: label)
            self.setToolbarItems([labelBtn], animated: true)
            navigationItem.title = "Search results"
        default:
            let glossaryButton = UIBarButtonItem(title: "Glossary",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(showGlossary))
            self.setToolbarItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), glossaryButton], animated: false)
            
            let preferencesButton = UIBarButtonItem(title: "⚙︎",
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(loadPreferences))
            
            let helpButton = UIBarButtonItem(title: "?",
                                             style: .plain,
                                             target: self,
                                             action: #selector(showHelp))
            
            navigationItem.leftBarButtonItem = preferencesButton
            navigationItem.rightBarButtonItem = helpButton
            navigationItem.title = "Tupšenna"
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateTableView),
                                                   name: Notification.Name("downloadedVolumesDidChange"),
                                                   object: nil)
        }
        registerForPreviewing(with: self, sourceView: self.tableView)
    }
    
    @objc func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func loadPreferences() {
        guard let preferencesViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.PreferencesViewController) else {return}
        navigationController?.pushViewController(preferencesViewController, animated: true)
    }
    
    @objc func showHelp() {
        let configuration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: configuration)
        guard let url = URL(string: "https://www.chaidk.me/manuals/tupshenna/") else {return}
        
        let request = URLRequest(url: url)
        let viewController = UIViewController()
        viewController.view = view
        view.load(request)
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.pushViewController(viewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if catalogue.texts.isEmpty && !noTextsLoadedPromptShownAlreadyInSession && catalogue.source != .search {
            let alert = UIAlertController(title: "No volumes downloaded",
                                          message: "There are no texts available to view. Download at least one text volume in Settings",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Go to Settings", style: .default, handler: {_ in self.loadPreferences()})
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(action)
            alert.addAction(cancel)
            present(alert, animated: true) {self.noTextsLoadedPromptShownAlreadyInSession = true}
        }
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
    
    func configureDetailViewController(for indexPath: IndexPath, peeking: Bool = false) -> TextEditionViewController? {
        guard let (catalogueEntry, textStrings) = getTextViewData(for: indexPath) else {return nil}
        
        let controller: TextEditionViewController
        if peeking {
            controller = TextEditionViewController()
        } else {
            controller = self.detailViewController ?? TextEditionViewController()
        }
        controller.textItem = catalogueEntry
        controller.textStrings = textStrings
        controller.catalogue = self.catalogue
        controller.parentController = self
        return controller
    }
    
    // MARK: - Segues
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {

        guard let controller = configureDetailViewController(for: indexPath) else {return}

        if catalogue.source == .search {
            guard let catalogue = self.catalogue as? Catalogue else {return}
            guard let textSearch = catalogue.catalogue as? TextSearchCollection else {return}
            let searchTerm = textSearch.searchTerm
            controller.searchTerm = searchTerm
        }
        
        let navigationController = controller.navigationController ?? UINavigationController(rootViewController: controller)
        splitViewController?.showDetailViewController(navigationController, sender: self)
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

extension ProjectListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return configureDetailViewController(for: indexPath, peeking: true)
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        splitViewController?.showDetailViewController(viewControllerToCommit, sender: self)
    }
    
    
}
