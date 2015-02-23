//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/23.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resizedImageWithBounds(bounds: CGSize) -> UIImage {
    
    // TODO: size.width 
    //println("size.height: \(size.height)")
    let horizontalRatio = bounds.width / size.width
    let veritcalRatio = bounds.height / size.height
    let ratio = min(horizontalRatio, veritcalRatio)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
    
  }

}
