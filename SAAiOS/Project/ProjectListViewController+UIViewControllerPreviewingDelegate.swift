//
//  ProjectListViewController+UIViewControllerPreviewingDelegate.swift
//  Tupšenna
//
//  Created by Chaitanya Kanchan on 13/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import UIKit

extension ProjectListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return configureDetailViewController(for: indexPath, peeking: true)
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        splitViewController?.showDetailViewController(viewControllerToCommit, sender: self)
    }
}
