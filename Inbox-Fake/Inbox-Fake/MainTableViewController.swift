//
//  MainTableViewController.swift
//  Inbox-Fake
//
//  Created by Miralem Cebic on 19/06/16.
//  Copyright © 2016 Miralem Cebic. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: UITableViewDelegate
extension MainTableViewController
{
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath

        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        present(controller, animated: true, completion: nil)
    }
}

// MARK: ExpandingTransitionPresentingViewController
extension MainTableViewController: ExpandingTransitionPresentingViewController
{
    func expandingTransitionTargetViewForTransition(_ transition: ExpandingCellTransition) -> UIView! {
        if let indexPath = selectedIndexPath {
            return tableView.cellForRow(at: indexPath)
        } else {
            return nil
        }
    }
}
