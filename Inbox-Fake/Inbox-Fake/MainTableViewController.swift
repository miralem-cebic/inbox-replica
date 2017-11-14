import UIKit

class MainTableViewController: UITableViewController {

    var selectedIndexPath: IndexPath?
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

        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: DetailViewController.identifier) as! DetailViewController
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
