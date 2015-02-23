//
//  MyLocations.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/21.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject, MKAnnotation {

  @NSManaged var latitude: Double
  //@NSManaged var date: NSTimeInterval
  @NSManaged var date: NSDate
  @NSManaged var locationDescription: String
  @NSManaged var category: String
  @NSManaged var placemark: CLPlacemark?
  @NSManaged var longitude: Double
  @NSManaged var photoID: NSNumber?

  
// MARK: - read only computed properties
  // Read-only computed properties
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  
  // == func title() -> String! {}
  var title: String! {
    if locationDescription.isEmpty {
      return "(NO Description)"
    } else {
      return locationDescription
    }
  }
  
  var subtitle: String! {
    return category
  }
  
  var hasPhoto: Bool {
    return photoID != nil
  }
  
  var photoPath: String {
    /*
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.integerValue).jpg"
    return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
    */
    
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.integerValue).jpg"
    return applicationDocumentsDirectory.stringByAppendingPathComponent(
      filename)
  }
  
  var photoImage: UIImage? {
    return UIImage(contentsOfFile: photoPath)
  }
  
  
  class func nextPhotoID() -> Int {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let currentID = userDefaults.integerForKey("photoID")  // initial is return 0
    userDefaults.setInteger(currentID + 1, forKey: "photoID")
    userDefaults.synchronize()
    return currentID
  }
  
  func removePhotoFile() {
      if hasPhoto {
        let path = photoPath
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
          var error: NSError?
          if !fileManager.removeItemAtPath(path, error: &error) {
            println("Error removing file: \(error!)")
          }
        }
      }
  }

}
