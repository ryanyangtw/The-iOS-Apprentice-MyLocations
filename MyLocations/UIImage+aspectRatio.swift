//
//  UIImage+aspectRatio.swift
//  MyLocations
//
//  Created by Ryan on 2015/3/6.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

extension UIImage {
  /* Return the aspect ratio of the image. (read-only) */
  var aspectRatio: CGFloat {
    return self.size.width/self.size.height
  }
  
}