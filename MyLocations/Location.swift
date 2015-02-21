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

class Location: NSManagedObject {

    @NSManaged var latitude: Double
    //@NSManaged var date: NSTimeInterval
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var longitude: Double

}
