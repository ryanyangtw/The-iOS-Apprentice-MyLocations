//
//  Functions.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/20.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
  let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
  
  dispatch_after(when, dispatch_get_main_queue(), closure)

}

let applicationDocumentsDirectory: String = {
  let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
  
  return paths[0]
}()





