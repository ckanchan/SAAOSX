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
    
    
    
    init(map: AncientMap, tableView: NSTableView) {
        self.ancientMap = map
        self.tableView = tableView
    }
}
