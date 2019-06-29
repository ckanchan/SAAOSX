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
    var sceneDelegate: SceneDelegate?
    lazy var catalogue: CatalogueProvider = {return sqlite}()
    lazy var searchController: UISearchController = initialiseSearchController()
    
    lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource

        #if !targetEnvironment(UIKitForMac)
        if self.catalogue.source != .search {
            let glossaryButton = UIBarButtonItem(title: "Glossary",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(showGlossary))
            
            self.setToolbarItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), glossaryButton],
                                 animated: false)
        }
        #endif
//        let gearImage = UIImage(systemName: "gear")
//        let preferencesButton = UIBarButtonItem(image: gear,
//                                                style: .plain,
//                                                target: self,
//                                                action: #selector(loadPreferences))
        //navigationItem.rightBarButtonItem = preferencesButton
    }
    
    @objc func loadPreferences() {
        guard let preferencesViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardID.PreferencesViewController) else {return}
        navigationController?.pushViewController(preferencesViewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       update(with: catalogue)
    }

    @objc func showGlossary(_ sender: Any?) {
        guard let glossaryController = storyboard?.instantiateViewController(withIdentifier: StoryboardID.Glossary) as? GlossaryTableViewController else {return}

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

        #if targetEnvironment(UIKitForMac)
        let userActivity = NSUserActivity(activityType: "me.chaidk.saai.glossary")
        userActivity.title = "View Glossary"
        
        let activationOptions = UIScene.ActivationRequestOptions()
        activationOptions.requestingScene = view.window?.windowScene
        
        UIApplication.shared.requestSceneSessionActivation(nil,
                                                           userActivity: userActivity,
                                                           options: activationOptions,
                                                           errorHandler: {print($0)})
        
        
        
        #else
        
        self.navigationController?.pushViewController(glossaryController, animated: true)
        
        #endif
    }

    // MARK: - Segues
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        guard let catalogueEntry = dataSource.itemIdentifier(for: indexPath),
            let textStrings = sqlite.getTextStrings(catalogueEntry.id),
        let controller = detailViewController else {return}
        
        controller.textItem = catalogueEntry
        controller.textStrings = textStrings
        
        #if !targetEnvironment(UIKitForMac)
        splitViewController?.showDetailViewController(controller.navigationController!, sender: self)
        sceneDelegate?.didChooseDetail = true
        detailViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailViewController?.navigationItem.leftItemsSupplementBackButton = true
        #endif
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
        guard let newIndexPath = getIndexPath(direction),
            tableView.cellForRow(at: newIndexPath) != nil,
            viewIfLoaded?.window != nil else {return}
        
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .middle)
    }
}

// MARK: - iOS 13 Table View Methods
extension ProjectListViewController {
    enum Section {
        case section
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Section, OraccCatalogEntry> {
        let reuseIdentifier = "Cell"
        
        return UITableViewDiffableDataSource(tableView: tableView,
                                             cellProvider: { tableView, indexPath, catalogueEntry in
                                                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                                                
                                                cell.textLabel?.text = catalogueEntry.displayName
                                                cell.detailTextLabel?.text = catalogueEntry.title
                                                return cell
                                                
        })
    }
    
    func update(with catalogue: CatalogueProvider) {
        let snapshot = NSDiffableDataSourceSnapshot<Section, OraccCatalogEntry>()
        snapshot.appendSections([Section.section])
        snapshot.appendItems(catalogue.texts, toSection: .section)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Search Controller methods
extension ProjectListViewController: UISearchResultsUpdating {
    
    func initialiseSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search texts"
        searchController.searchBar.addShortcuts()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        return searchController
    }
    
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
    static func new(detailViewController: TextEditionViewController?, sceneDelegate: SceneDelegate? = nil) -> ProjectListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: UIViewController.StoryboardID.ProjectListViewController) as! ProjectListViewController
        vc.detailViewController = detailViewController
        vc.sceneDelegate = sceneDelegate
        return vc
    }
}
