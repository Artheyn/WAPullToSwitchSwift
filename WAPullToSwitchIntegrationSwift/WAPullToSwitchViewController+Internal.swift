//
//  WAPullToSwitchViewController_Private.swift
//  WAPullToSwitchIntegrationSwift
//
//  Created by Alexandre KARST on 15/05/2015.
//  Copyright (c) 2015 Alexandre KARST. All rights reserved.
//

import Foundation
import UIKit


extension WAPullToSwitchViewController {
// MARK: - Scroll configuration
    
    // Retrieve views and configuration data from dataSource and build the UIScrollView(s).
    internal func configureScrollViews() {
        
        // Ensure that we have a dataSource.
        assert(self.dataSource != nil, "ERROR - WAScrollGravitySwitchViewController : dataSource is nil. You must specified a dataSource before you can load the component view.");
        
        // Request the two views which will be switched.
        let viewOne: UIView? = self.dataSource!.viewForIndex(0)
        let viewTwo: UIView? = self.dataSource!.viewForIndex(1)
        
        // Ensure that we have the two views to switch between.
        assert( (viewOne != nil && viewTwo != nil), "ERROR - WAScrollGravitySwitchViewController : one of the scroll view requested is nil.");
        
        self.scrollViewFirst = self.encapsulateViewInScrollView(viewOne!)
        self.scrollViewSecond = self.encapsulateViewInScrollView(viewTwo!)
        
        // Request for gravity/elasticity dataSource values.
        self.retrieveDataSourceConfiguration()
        
        // Add views to our component and present the first one.
        self.view.addSubview(self.scrollViewFirst!)
        self.view.addSubview(self.scrollViewSecond!)
        self.view.bringSubviewToFront(self.scrollViewFirst!)
        
        // Change the origin of the first scroll to fit in position (0,0).
        var frameScroll: CGRect = self.scrollViewFirst!.frame
        frameScroll.origin.x = 0.0;
        frameScroll.origin.y = 0.0;
        self.scrollViewFirst?.frame = frameScroll
        
        
        // Change the origin of the second scroll to hide it.
        frameScroll = self.scrollViewSecond!.frame
        frameScroll.origin.x = 0.0
        frameScroll.origin.y = CGRectGetHeight(self.view.frame)
        self.scrollViewSecond?.frame = frameScroll
        
        // Setup delegation.
        self.scrollViewFirst?.delegate = self
        self.scrollViewSecond?.delegate = self
    }
    
    // Ask the dataSource for configurations values.
    internal func retrieveDataSourceConfiguration () {
        
        var requestedBounceGravity: Float = 0.0
        var requestedHideGravity: Float = 0.0
        var requestedBounceElasticity: Float = 0.0
        
        if let bounceGravityConfig = self.animationConfiguration?.gravityVectorYComponentForBounce() {
            requestedBounceGravity = bounceGravityConfig
        }
        
        
        if let hideGravityConfig = self.animationConfiguration?.gravityVectorYComponentForHide() {
            requestedHideGravity = hideGravityConfig
        }
        
        if let bounceElasticityConfig = self.animationConfiguration?.elasticityCoefficientForBounce() {
            requestedBounceElasticity = bounceElasticityConfig
        }
        
        bounceGravity = requestedBounceGravity != 0.0 ? requestedBounceGravity :  WAPULLTOSWITCH_DEFAULT_BOUNCE_GRAVITY;
        hideGravity = requestedHideGravity != 0.0 ? requestedHideGravity : WAPULLTOSWITCH_DEFAULT_HIDE_GRAVITY;
        bounceElasticity = requestedBounceElasticity != 0.0 ? requestedBounceElasticity : WAPULLTOSWITCH_DEFAULT_BOUNCE_ELASTICITY;
        
    }
    
    // Used to encapsulate a requested view from the dataSource in a UIScrollView.
    internal func encapsulateViewInScrollView(view: UIView) -> UIScrollView {
        
        let scrollViewContainer = UIScrollView(frame: CGRectNull)
        
        scrollViewContainer.contentSize = view.frame.size
        scrollViewContainer.alwaysBounceVertical = true
        scrollViewContainer.showsVerticalScrollIndicator = false
        scrollViewContainer.autoresizesSubviews = false
        scrollViewContainer.addSubview(view)
        
        return scrollViewContainer
    }
    
    internal func currentScrollView() -> UIScrollView? {
        return (scrollState == WAScrollGravitySwitchState.WAScrollGravitySwitchStateFirst) ? scrollViewFirst : scrollViewSecond
    }
    
// MARK: - Animation management
    
    // Reset animators and place the active view on the top of the stack.
    internal func resetAnimatorsAndUpdateCurrentScrollZIndex(scrollView: UIScrollView) {
        
        animatorHideView.removeAllBehaviors()
        animatorBounceView.removeAllBehaviors()
        self.view.bringSubviewToFront(scrollView)
    }
    
    // Bounce the current UIScrollView with a defined elasticity and a gravity effect.
    internal func bounceCurrentScroll() {
        
        
        var scrollView = self.currentScrollView()

        // Save the current offset.
        let yOffset = scrollView?.contentOffset.y
        
        // Move the origin of the scroll by the size of the offset.
        var frameScroll = scrollView?.frame
        frameScroll?.origin.y -= yOffset!
        scrollView?.frame = frameScroll!
 
        
        // Create animation.
        let animator = UIDynamicAnimator()
        
        // -- Gravity.
        let gravityBehavior = UIGravityBehavior(items: [scrollView!])
        gravityBehavior.gravityDirection = CGVectorMake(CGFloat(0.0), CGFloat(bounceGravity))
        
        // -- Collision.
        let collisionBehavior = UICollisionBehavior(items: [scrollView!])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        let frameSelfView = self.view.frame
        
        // The collision will occured with the top border of the WAScrollGravitySwitchViewController (self) view.
        collisionBehavior.addBoundaryWithIdentifier("Segment", fromPoint: CGPointMake(CGFloat(0.0), CGFloat(-1.0)), toPoint: CGPointMake(frameSelfView.size.width, CGFloat(-1.0)))
        
        
        // -- Properties : elasticity.
        let propertiesBehavior = UIDynamicItemBehavior(items: [scrollView!])
        propertiesBehavior.elasticity = CGFloat(bounceElasticity)
        
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
        animator.addBehavior(propertiesBehavior)

        
        
        // Fade in for the next displayed view.
        UIView.beginAnimations("FadeIn", context: nil)
        UIView.setAnimationDuration(1.0)
        scrollView?.alpha = 1.0
        UIView.commitAnimations()
        
        self.animatorBounceView = animator
        
    }
    
    // Hide the current UIScrollView with a gravity effect.
    internal func hideCurrentScroll() {
        
        let scrollView = self.currentScrollView()
        
        // Get the scroll current offset and place his origin to this point.
        let yOffset = scrollView?.contentOffset.y
        var frameScroll = scrollView?.frame
        frameScroll?.origin.y = frameScroll!.origin.y - yOffset! - 20
        scrollView?.frame = frameScroll!
        
        
        // Create animation.
        let animator = UIDynamicAnimator()
        
        // -- Gravity.
        let gravityBehavior = UIGravityBehavior(items: [scrollView!])
        gravityBehavior.gravityDirection = CGVectorMake(CGFloat(0.0), CGFloat(hideGravity))
        
        // -- Collision.
        let collisionBehavior = UICollisionBehavior(items: [scrollView!])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        let frameSelfView = self.view.frame
        
        
        // The collision will occured with the top border of the WAScrollGravitySwitchViewController (self) view.
        var bottomStopLineY: CGFloat = frameSelfView.size.height
        bottomStopLineY += scrollView!.frame.size.height
        bottomStopLineY += 50.0
        collisionBehavior.addBoundaryWithIdentifier("Segment", fromPoint: CGPointMake(CGFloat(0.0), bottomStopLineY), toPoint: CGPointMake(frameSelfView.size.width, bottomStopLineY))
        
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
        
        self.animatorHideView = animator
        
        // Fade out for the hidden view.
        UIView.beginAnimations("FadeOut", context: nil)
        UIView.setAnimationDuration(1.0)
        scrollView?.alpha = 0.0
        UIView.commitAnimations()

    }
    
    // Switch between the active and inactive view with animation.
    internal func switchScroll() {
        
        self.disableScroll()
        self.hideCurrentScroll()
        self.switchState()
        self.bounceCurrentScroll()
    }
    
    // Enable scroll on scroll views.
    internal func enableScroll() {
        
        scrollViewFirst?.scrollEnabled = true
        scrollViewSecond?.scrollEnabled = true
    }
    
    // Disable scroll on scroll views.
    internal func disableScroll() {
        
        scrollViewFirst?.scrollEnabled = false
        scrollViewSecond?.scrollEnabled = false
    }
    
// MARK: - Attributes management
    
    // Switch the state so that it reflects the current displayed scrollView.
    internal func switchState() {
        // Update the current state.
        scrollState = (scrollState == WAScrollGravitySwitchState.WAScrollGravitySwitchStateFirst) ? WAScrollGravitySwitchState.WAScrollGravitySwitchStateSecond : WAScrollGravitySwitchState.WAScrollGravitySwitchStateFirst;
    }
}
