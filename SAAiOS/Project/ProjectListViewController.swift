//
//  ProjectListViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import CDKSwiftOracc
import UIKit
import WebKit

class ProjectListViewController: UITableViewController {
    
    // MARK: - Instance Variables
    var noTextsLoadedPromptShownAlreadyInSession: Bool = false
    var detailViewController: TextEditionViewController?
    var filteredTexts: [OraccCatalogEntry] = []
    lazy var catalogue: CatalogueProvider = { return sqlite }()
    lazy var searchController: UISearchController = { return makeSearchController() }()

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbars()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableView),
                                               name: Notification.Name("downloadedVolumesDidChange"),
                                               object: nil)
        
        registerForPreviewing(with: self, sourceView: self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if catalogue.texts.isEmpty
            && !noTextsLoadedPromptShownAlreadyInSession
            && catalogue.source != .search {
            present(noTextsAlert, animated: true) {self.noTextsLoadedPromptShownAlreadyInSession = true}
        }
    }
    
    @objc func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    
    func configureDetailViewController(for indexPath: IndexPath, peeking: Bool = false) -> TextEditionViewController? {
        guard let (catalogueEntry, textStrings) = getTextViewData(for: indexPath) else {return nil}
        
        let controller = peeking ? TextEditionViewController() : (self.detailViewController ?? TextEditionViewController())
        controller.textItem = catalogueEntry
        controller.textStrings = textStrings
        controller.catalogue = self.catalogue
        controller.parentController = self
        return controller
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        guard let controller = configureDetailViewController(for: indexPath) else {return}

        if catalogue.source == .search {
            guard let catalogue = self.catalogue as? Catalogue,
                let textSearch = catalogue.catalogue as? TextSearchCollection
                else {return}
            
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
        let catalogueEntry = isFiltering ? filteredTexts[indexPath.row] : catalogue.texts[indexPath.row]
        guard let textStrings = sqlite.getTextStrings(catalogueEntry.id) else {return nil}
        return (catalogueEntry, textStrings)
    }
}

// MARK: - Table view methods
extension ProjectListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTexts.count : catalogue.texts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let textItem = isFiltering ? filteredTexts[indexPath.row] : catalogue.texts[indexPath.row]
        cell.textLabel?.text = textItem.displayName
        cell.detailTextLabel?.text = textItem.title
        return cell
    }
}

// MARK: - Segues and Navigation

extension ProjectListViewController {
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

@objc extension ProjectListViewController {
    func loadPreferences() {
        guard let preferencesViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.PreferencesViewController) else {return}
        navigationController?.pushViewController(preferencesViewController, animated: true)
    }
    func showHelp() {
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
    
    func showGlossary(_ sender: Any?) {
        guard let glossaryController = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.Glossary) as? GlossaryTableViewController else {return}
        
        if let quickDefinition = sender as? UIBarButtonItem,
            let text = quickDefinition.title,
            text != "Glossary" {
            let cf = text.prefix(while: {$0 != ":"})
            if !cf.isEmpty {
                glossaryController.searchController.isActive = true
                glossaryController.searchController.searchBar.text = String(cf)
                glossaryController.searchController.searchBar.selectedScopeButtonIndex = 0
                glossaryController.updateSearchResults(for: glossaryController.searchController)
            }
        }
        
        self.navigationController?.pushViewController(glossaryController, animated: true)
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

extension ProjectListViewController {
    var noTextsAlert: UIAlertController {
        let title = "No volumes downloaded"
        let message = "There are no texts available to view. Download at least one text volume in Settings"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Go to Settings", style: .default, handler: {_ in self.loadPreferences()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        return alert
    }
}
