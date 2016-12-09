//
//  ExpandingCellTransition.swift
//  Inbox-Fake
//
//  Created by Miralem Cebic on 19/06/16.
//  Copyright © 2016 Miralem Cebic. All rights reserved.
//

import UIKit

enum TransitionType {
    case none
    case presenting
    case dismissing
}

enum TransitionState {
    case initial
    case final
}

private let kExpandingCellTransitionDuration: TimeInterval = 0.6

class ExpandingCellTransition: NSObject,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate
{

    var type: TransitionType = .none
    var presentingController: UIViewController!
    var presentedController: UIViewController!

    var targetSnapshot: UIView!
    var targetContainer: UIView!

    var topRegionSnapshot: UIView!
    var bottomRegionSnapshot: UIView!
    var navigationBarSnapshot: UIView!


    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return kExpandingCellTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView


        var foregroundViewController = toViewController
        var backgroundViewController = fromViewController

        if type == .dismissing {
            foregroundViewController = fromViewController
            backgroundViewController = toViewController
        }

        // get target view
        var targetViewController = backgroundViewController
        if let navController = targetViewController as? UINavigationController {
            targetViewController = navController.topViewController!
        }
        let targetViewMaybe = (targetViewController as? ExpandingTransitionPresentingViewController)?.expandingTransitionTargetViewForTransition(self)

        assert(targetViewMaybe != nil, "Cannot find target view in background view controller")

        let targetView = targetViewMaybe!

        // setup animation
        let targetFrame = backgroundViewController.view.convert(targetView.frame, from: targetView.superview)
        if type == .presenting {
            sliceSnapshotsInBackgroundViewController(backgroundViewController, targetFrame: targetFrame, targetView: targetView)
            (foregroundViewController as? ExpandingTransitionPresentedViewController)?.expandingTransition(self, navigationBarSnapshot: navigationBarSnapshot)
        } else {
            navigationBarSnapshot.frame = containerView.convert(navigationBarSnapshot.frame, from: navigationBarSnapshot.superview)
        }

        targetContainer.addSubview(foregroundViewController.view)
        containerView.addSubview(targetContainer)
        containerView.addSubview(topRegionSnapshot)
        containerView.addSubview(bottomRegionSnapshot)
        containerView.addSubview(navigationBarSnapshot)

        let width = backgroundViewController.view.bounds.width
        let height = backgroundViewController.view.bounds.height

        let preTransition: TransitionState = (type == .presenting ? .initial : .final)
        let postTransition: TransitionState = (type == .presenting ? .final : .initial)

        configureViewsToState(preTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)

        // perform animation
        backgroundViewController.view.isHidden = true
        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 0,
                                   options: UIViewAnimationOptions(),
                                   animations: { () -> Void in
            self.configureViewsToState(postTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)

            if self.type == .presenting {
                self.navigationBarSnapshot.frame.size.height = 0
            }


            }, completion: {
                (finished) in
                self.targetContainer.removeFromSuperview()
                self.topRegionSnapshot.removeFromSuperview()
                self.bottomRegionSnapshot.removeFromSuperview()
                self.navigationBarSnapshot.removeFromSuperview()
                
                containerView.addSubview(foregroundViewController.view)
                backgroundViewController.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingController = presenting
        if let navController = presentingController as? UINavigationController {
            presentingController = navController.topViewController
        }

        if presentingController is ExpandingTransitionPresentingViewController {
            type = .presenting
            return self
        } else {
            type = .none
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presentingController is ExpandingTransitionPresentingViewController {
            type = .dismissing
            return self
        } else {
            type = .none
            return nil
        }
    }

    func sliceSnapshotsInBackgroundViewController(_ backgroundViewController: UIViewController, targetFrame: CGRect, targetView: UIView) {
        let view = backgroundViewController.view
        let width = view?.bounds.width
        let height = view?.bounds.height

        // create top region snapshot
        topRegionSnapshot = view?.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: width!, height: targetFrame.minY), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)

        // create bottom region snapshot
        bottomRegionSnapshot = view?.resizableSnapshotView(from: CGRect(x: 0, y: targetFrame.maxY, width: width!, height: height!-targetFrame.maxY), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)

        // create target view snapshot
        targetSnapshot = targetView.snapshotView(afterScreenUpdates: false)
        targetContainer = UIView(frame: targetFrame)
        targetContainer.backgroundColor = UIColor.white
        targetContainer.clipsToBounds = true
        targetContainer.addSubview(targetSnapshot)

        // create navigation bar snapshot
        if let navController = backgroundViewController as? UINavigationController {
            let barHeight = navController.navigationBar.frame.maxY

            UIGraphicsBeginImageContext(CGSize(width: width!, height: barHeight))
            view?.drawHierarchy(in: (view?.bounds)!, afterScreenUpdates: false)
            let navigationBarImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            navigationBarSnapshot = UIImageView(image: navigationBarImage)
            navigationBarSnapshot.backgroundColor = navController.navigationBar.barTintColor
            navigationBarSnapshot.contentMode = .bottom
        }
    }

    func configureViewsToState(_ state: TransitionState, width: CGFloat, height: CGFloat, targetFrame: CGRect, fullFrame: CGRect, foregroundView: UIView) {
        switch state {
        case .initial:
            topRegionSnapshot.frame = CGRect(x: 0, y: 0, width: width, height: targetFrame.minY)
            bottomRegionSnapshot.frame = CGRect(x: 0, y: targetFrame.maxY, width: width, height: height-targetFrame.maxY)
            targetContainer.frame = targetFrame
            targetSnapshot.alpha = 1
            foregroundView.alpha = 0
            navigationBarSnapshot.sizeToFit()

        case .final:
            topRegionSnapshot.frame = CGRect(x: 0, y: -targetFrame.minY, width: width, height: targetFrame.minY)
            bottomRegionSnapshot.frame = CGRect(x: 0, y: height, width: width, height: height-targetFrame.maxY)
            targetContainer.frame = fullFrame
            targetSnapshot.alpha = 0
            foregroundView.alpha = 1
        }
    }
}

@objc
protocol ExpandingTransitionPresentingViewController {
    func expandingTransitionTargetViewForTransition(_ transition: ExpandingCellTransition) -> UIView!
}

@objc
protocol ExpandingTransitionPresentedViewController {
    func expandingTransition(_ transition: ExpandingCellTransition, navigationBarSnapshot: UIView)
}
