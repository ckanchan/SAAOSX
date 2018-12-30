//
//  AncientMapTableViewDelegate.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 29/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class AncientMapTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var ancientMap: AncientMap
    weak var tableView: NSTableView?
    weak var mapDelegate: AncientMapViewDelegate?
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ancientMap.siteCount
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        
        guard let (qpnID, ancientLocation) = ancientMap.getLocationAtIndex(row) else {return nil}
        
        enum TableColumns: String {
            case col1, col2
        }
        
        switch tableColumn?.identifier.rawValue {
        case TableColumns.col1.rawValue:
            view.textField?.stringValue = qpnID
            
        case TableColumns.col2.rawValue:
            view.textField?.stringValue = ancientLocation.title ?? "n/a"
            
        default:
            break
        }
            
        return view
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let row = tableView?.selectedRow else { return }
        guard let (qpnID, _) = ancientMap.getLocationAtIndex(row) else { return }
        mapDelegate?.selectAnnotation(qpnID: qpnID)
    }
    
    
    
    init(map: AncientMap, tableView: NSTableView, mapViewDelegate: AncientMapViewDelegate?) {
        self.ancientMap = map
        self.tableView = tableView
        self.mapDelegate = mapViewDelegate
    }
}
