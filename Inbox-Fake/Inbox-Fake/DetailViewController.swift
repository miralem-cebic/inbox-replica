//
//  DetailViewController.swift
//  Inbox-Fake
//
//  Created by Miralem Cebic on 19/06/16.
//  Copyright © 2016 Miralem Cebic. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView : UIView!
    
    let transition = ExpandingCellTransition()

    var navigationBarSnapshot: UIView!
    var navigationBarHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height*2);
        self.transitioningDelegate = transition
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if navigationBarSnapshot != nil {
            navigationBarSnapshot.frame.origin.y = -navigationBarHeight
            scrollView.addSubview(navigationBarSnapshot)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if scrollView.contentOffset.y < -navigationBarHeight/2 {
            return .LightContent
        }
        return .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: ExpandingTransitionPresentedViewController
extension DetailViewController: ExpandingTransitionPresentedViewController {

    func expandingTransition(transition: ExpandingCellTransition, navigationBarSnapshot: UIView) {
        self.navigationBarSnapshot = navigationBarSnapshot
        self.navigationBarHeight = navigationBarSnapshot.frame.height
    }
}

// MARK: UIScrollViewDelegate
extension DetailViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isBeingDismissed() {
            navigationBarSnapshot.frame = CGRect(x: 0, y: scrollView.contentOffset.y, width: view.bounds.width, height: -scrollView.contentOffset.y)
        }

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            [self]
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -navigationBarHeight/2 {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
