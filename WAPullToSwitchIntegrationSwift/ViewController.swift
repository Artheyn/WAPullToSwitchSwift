//
//  ViewController.swift
//  WAPullToSwitchIntegrationSwift
//
//  Created by Alexandre KARST on 15/05/2015.
//  Copyright (c) 2015 Alexandre KARST. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WAPullToSwitchDataSource, WAPullToSwitchAnimationConfiguration {
    
    private
    
    var pullToSwitchViewController = WAPullToSwitchViewController()
    
    
    // MARK: - View lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Instantiate our component and setup the data source.
        pullToSwitchViewController.dataSource = self
        pullToSwitchViewController.animationConfiguration = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let componentView = pullToSwitchViewController.view
        
        // Add the component view to our current view.
        self.view.addSubview(componentView)
        
        // Setup the component to fit its superview.
        let fitSuperviewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[componentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["componentView": componentView])
        
        let fitSuperviewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[componentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["componentView": componentView])
        
        self.view.addConstraints(fitSuperviewConstraintsHorizontal)
        self.view.addConstraints(fitSuperviewConstraintsVertical)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - WAPullToSwitchDataSource
    
    func viewForIndex(index: Int) -> UIView {
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let screenHeight = UIScreen.mainScreen().applicationFrame.size.height
        let view = UIView(frame: CGRectMake(0.0, 0.0, screenWidth, screenHeight + 200.0))
        
        if index % 2 == 0 {
            view.backgroundColor = UIColor.lightGrayColor()
        } else {
            view.backgroundColor = UIColor.brownColor()
        }
        
        return view
    }
    
    
    // MARK: - WAPullToSwitchAnimationConfiguration
    
    func gravityVectorYComponentForHide() -> Float {
        return Float(4.0)
    }
    
    func gravityVectorYComponentForBounce() -> Float {
        return Float(-3.0)
    }
    
    func elasticityCoefficientForBounce() -> Float {
        return Float(0.3)
    }

}

