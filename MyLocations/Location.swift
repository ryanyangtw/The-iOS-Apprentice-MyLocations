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
  
  
  

}
