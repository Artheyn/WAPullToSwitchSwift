//
//  WAPullToSwitchViewController.swift
//  WAPullToSwitchIntegrationSwift
//
//  Created by Alexandre KARST on 15/05/2015.
//  Copyright (c) 2015 Alexandre KARST. All rights reserved.
//

import Foundation
import UIKit

enum WAScrollGravitySwitchState {
    case WAScrollGravitySwitchStateFirst
    case WAScrollGravitySwitchStateSecond
};


public class WAPullToSwitchViewController: UIViewController, UIScrollViewDelegate {
    
// MARK: - @private instance variables
    private
    
    // Flag to know if the user ended a dragging gesture.
    var boolEndDragging: Bool = true
    
    // Physics animation flags.
    var bounceElasticity: Float = WAPULLTOSWITCH_DEFAULT_BOUNCE_ELASTICITY
    var bounceGravity: Float = WAPULLTOSWITCH_DEFAULT_BOUNCE_GRAVITY
    var hideGravity: Float = WAPULLTOSWITCH_DEFAULT_HIDE_GRAVITY

    // Animators to respectively bounce or hide a UIScrollView.
    var animatorBounceView: UIDynamicAnimator = UIDynamicAnimator()
    var animatorHideView: UIDynamicAnimator = UIDynamicAnimator()
    
    // Two different scroll views to encapsulate the view we want to switch between.
    var scrollViewFirst: UIScrollView?
    var scrollViewSecond: UIScrollView?
    
    
// MARK: - @internal instance variables
    internal
    
    // State which indicates which view is active.
    var scrollState: WAScrollGravitySwitchState = WAScrollGravitySwitchState.WAScrollGravitySwitchStateFirst;
    

// MARK: - @public instance variables
    public
    var dataSource: WAPullToSwitchDataSource?
    var animationConfiguration: WAPullToSwitchAnimationConfiguration?
    
    
// MARK: - View lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve scroll views and configure them
        self.configureScrollViews()
        
        // We hide content out of bounds
        self.view.clipsToBounds = true
    }
    
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        var frameScrollComponent = self.view.frame;
        var frameScrollViewFirst = scrollViewFirst!.frame;
        var frameScrollViewSecond = scrollViewSecond!.frame;
        

        
        // Update the scroll frames so it fit entirely the component frame.
        self.scrollViewFirst?.frame = CGRectMake(CGRectGetMinX(frameScrollViewFirst), CGRectGetMinY(frameScrollViewFirst), CGRectGetWidth(frameScrollComponent), CGRectGetHeight(frameScrollComponent))
        self.scrollViewSecond?.frame = CGRectMake(CGRectGetMinX(frameScrollViewSecond), CGRectGetMinY(frameScrollViewSecond), CGRectGetWidth(frameScrollComponent), CGRectGetHeight(frameScrollComponent))
        
        
//        let constraintViewFirstFitToSuperview:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollViewFirst]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["scrollViewFirst": scrollViewFirst!])
//        
//        let constraintViewSecondFitToSuperview:[AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollViewSecond]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["scrollViewSecond": scrollViewSecond!])
//        
//        self.view.addConstraints(constraintViewFirstFitToSuperview)
//        self.view.addConstraints(constraintViewSecondFitToSuperview)
    }
    
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear animators.
        self.animatorBounceView.removeAllBehaviors()
        self.animatorHideView.removeAllBehaviors()
    }
    
    
// MARK: - (UIScrollViewDelegate) implementation
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        boolEndDragging = false;
        self.enableScroll()
    }
    
    

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let contentViewBigger = (CGRectGetHeight(scrollView.frame) >= scrollView.contentSize.height)
        let contentOffsetNotZero = scrollView.contentOffset.y > 0.0
        
        // If the contentView inside the scrollView isn't bigger than the scrollView bounds
        // we bypass the bounce scroll of the scrollView.
        if contentOffsetNotZero && contentViewBigger {
            scrollView.contentOffset = CGPointMake(0.0, 0.0)
        }
        
        
        // If the user "pull down" gesture is below a specified offset, we just replace the current view with a bounce animation.
        let offsetBelowLimit = scrollView.contentOffset.y >= CGFloat(WAPULLTOSWITCH_DEFAULT_SWITCH_LIMIT)
        let offsetBelowZero = scrollView.contentOffset.y < -0.0
        
        if boolEndDragging && offsetBelowLimit && offsetBelowZero {
            boolEndDragging = false
            // We bounce the current scroll.
            self.bounceCurrentScroll()
        }
        
        let offsetAboveLimit = scrollView.contentOffset.y < CGFloat(WAPULLTOSWITCH_DEFAULT_SWITCH_LIMIT)
        
        // If the user "pull down" gesture is above a specified offset, we switch between the two views.
        if boolEndDragging && offsetAboveLimit {
            boolEndDragging = false
            self.switchScroll()
        }
        
    }
    
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0.0 {
            boolEndDragging = true
        }
    }
    
    
    
}