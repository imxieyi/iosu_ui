//
//  TransparentNavigationController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/9.
//  Copyright © 2017年 xieyi. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/18881427/ios-7-view-with-transparent-content-overlaps-previous-view

import Foundation
import UIKit

class TransparentNaviCtrl:UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = PushTransition(op: operation)
        return transition
    }
    
}

class PushTransition:NSObject, UIViewControllerAnimatedTransitioning {
    
    var operation:UINavigationControllerOperation
    
    init(op:UINavigationControllerOperation) {
        operation = op
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // the containerView is the superview during the animation process.
        let container = transitionContext.containerView
        let from = transitionContext.view(forKey: .from)
        let to = transitionContext.view(forKey: .to)
        let width = container.frame.size.width
        
        // Set the needed frames to animate.
        var toInitialFrame = container.frame
        var fromDestinationFrame = from?.frame
        
        if operation == .push {
            toInitialFrame.origin.x = width
            to?.frame = toInitialFrame
            fromDestinationFrame?.origin.x = -width
        } else if operation == .pop {
            toInitialFrame.origin.x = -width
            to?.frame = toInitialFrame
            fromDestinationFrame?.origin.x = width
        }
        
        container.addSubview(to!)
        
        // Create a screenshot of the fromView
        let fromshot = (from?.snapshotView(afterScreenUpdates: false))!
        fromshot.frame = (from?.frame)!
        container.addSubview(fromshot)
        
        from?.removeFromSuperview()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1000, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //move.frame = container.frame
            to?.frame = container.frame
            fromshot.frame = fromDestinationFrame!
        }, completion: { finished in
            if !container.subviews.contains(to!) {
                container.addSubview(to!)
            }
            
            fromshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
}
