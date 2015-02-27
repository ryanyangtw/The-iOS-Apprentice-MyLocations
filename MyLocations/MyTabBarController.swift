//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/25.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
  
    return .LightContent
  }
  
  
  override func childViewControllerForStatusBarStyle() -> UIViewController? {
    
    return nil
    
  }


}
