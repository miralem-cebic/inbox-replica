//
//  ExpandingCellTransition.swift
//  Inbox-Fake
//
//  Created by Miralem Cebic on 19/06/16.
//  Copyright © 2016 Miralem Cebic. All rights reserved.
//

import UIKit

private let kExpandingCellTransitionDuration: NSTimeInterval = 0.6

class ExpandingCellTransition: NSObject,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate
{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return kExpandingCellTransitionDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()

        // setup animation
        containerView!.addSubview(fromViewController.view)
        containerView!.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        // perform animation
        UIView.animateWithDuration(duration,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: .CurveEaseInOut,
                                   animations: { () -> Void in
            [self]
            toViewController.view.alpha = 1
            }, completion: {
                (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}