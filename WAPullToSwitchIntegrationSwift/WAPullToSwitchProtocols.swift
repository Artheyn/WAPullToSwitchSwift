//
//  WAPullToSwitch_Protocols.swift
//  WAPullToSwitchIntegrationSwift
//
//  Created by Alexandre KARST on 19/05/2015.
//  Copyright (c) 2015 Alexandre KARST. All rights reserved.
//

import Foundation
import UIKit


public protocol WAPullToSwitchDataSource {
    // Ask the DataSource object for the view at the specified index.
    func viewForIndex(index: Int) -> UIView
}

public protocol WAPullToSwitchAnimationConfiguration {
    // Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_BOUNCE_GRAVITY.
    func gravityVectorYComponentForBounce() -> Float
    // Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_BOUNCE_ELASTICITY.
    func elasticityCoefficientForBounce() -> Float
    // Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_HIDE_GRAVITY
    func gravityVectorYComponentForHide() -> Float
}