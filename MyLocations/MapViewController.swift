//
//  MapViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/22.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var locations = [Location]()
  
  //var managedObjectContext: NSManagedObjectContext!

  var managedObjectContext: NSManagedObjectContext! {
    didSet {
      NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext, queue: NSOperationQueue.mainQueue()) { notification in
        
        
        // Exercise p.218: reloading of the locations more efficient by not re-fetching the entire list of Location objects (page 218)
        if self.isViewLoaded() {
          
          if let dictionary = notification.userInfo {
            if dictionary["inserted"] != nil {
              println("dictionary inserted")
              
              if let inserted: AnyObject = dictionary["inserted"] {
                let asSet = inserted as! NSSet
                let asArray = asSet.allObjects as! [Location]
                self.mapView.addAnnotations(asArray)
              }
              
              /*
              let insertedLocation = dictionary["inserted"] as? [Location]
              self.mapView.addAnnotations(self.locations)
              */
            }
            
            if dictionary["deleted"] != nil {
              println("dictionary deleted")
              if let deleted: AnyObject = dictionary["deleted"] {
                let asSet = deleted as! NSSet
                let asArray = asSet.allObjects as! [Location]
                self.mapView.removeAnnotations(asArray)
                
              }
              
              /*
              let deletedLocation = dictionary["deleted"] as? [Location]
              //println("deletedLocation: \(deletedLocation)")
              */
            }
            
            if dictionary["updated"] != nil {
              
              println("dictionary updated")
              if let updated: AnyObject = dictionary["updated"] {
                let asSet = updated as! NSSet
                let asArray = asSet.allObjects as! [Location]
                self.mapView.removeAnnotations(asArray)
                self.mapView.addAnnotations(asArray)
              }
              
              /*
              let updatedLocation = dictionary["updated"] as? [Location]
              self.mapView.removeAnnotations(updatedLocation)
              self.mapView.addAnnotations(updatedLocation)
              */
            }
          }
        }
        
        /*
        if self.isViewLoaded() {
          self.updateLocations()
        }
        */
      }
    }
  }
  
  override func viewDidLoad() {
    println("In mapViewController viewDidLoad")
    super.viewDidLoad()
    
    updateLocations()
    
    if !locations.isEmpty {
      showLocations()
    }

      // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  
  
  
  
// MARK: - Method
  func updateLocations() {
    println("In updateLocations")
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
    
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entity
    
    var error: NSError?
    let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
    
    if foundObjects == nil {
      fatalCoreDataError(error)
      return
    }
    
    // Remove the old objects
    mapView.removeAnnotations(locations)
    
    locations = foundObjects as! [Location]
    mapView.addAnnotations(locations)
    
  }
  
  
  func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
  
    var region: MKCoordinateRegion
    
    switch annotations.count {
      
      // no annotations
      case 0:
        region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
      // only one annotation
      case 1:
        let annotation = annotations[annotations.count - 1]
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
      // two or more annotation
      default:
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
      
        for annotation in annotations {
          topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
          
          topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
          
          bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
          
          bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
        }
      
        let center = CLLocationCoordinate2D(
          latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
          longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
      
        let extraSpace = 1.1
        let span = MKCoordinateSpan(
          latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
          longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace )
      
      
        region = MKCoordinateRegion(center: center, span: span)
  
    }
    
    return mapView.regionThatFits(region)
  
  }
  
  func showLocationDetails(sender: UIButton) {
    
    performSegueWithIdentifier("EditLocation", sender: sender)
  }
  

// MARK: - Action
  
  @IBAction func showUser() {
    let region = MKCoordinateRegionMakeWithDistance(
      mapView.userLocation.coordinate, 1000, 1000)
    
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
    
  }
  
  @IBAction func showLocations() {
    let region = regionForAnnotations(locations)
    mapView.setRegion(region, animated: true)
  }
  
  
// MARK: - Prepare For Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EditLocation" {
      let navigationController = segue.destinationViewController as! UINavigationController
    
      let controller = navigationController.topViewController as! LocationDetailsViewController
    
      controller.managedObjectContext = managedObjectContext
      
      let button = sender as! UIButton
      
      //println("***in prepareforsegue button.tag: \(button.tag)")
      let location = locations[button.tag]
      controller.locationToEdit = location
      
      
      
      
    }
  }
  
}


extension MapViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
  
    // 1 is: type check operator. Determine whether the annotation is really a Location object
    if annotation is Location {
    
      // 2
      let identifier = "Location"
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
      
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
  
        // 3
        annotationView.enabled = true
        annotationView.canShowCallout = true
        annotationView.animatesDrop = false
        annotationView.pinColor = .Green
        
        annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
        
        // 4 Implement target-action pattern manually
        let rightButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        
        rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
        
        annotationView.rightCalloutAccessoryView = rightButton
      
      } else {
        annotationView.annotation = annotation
      }
  
      // 5
      let button = annotationView.rightCalloutAccessoryView as! UIButton
      if let index = find(locations, annotation as! Location) {
        button.tag = index
      }
      
      return annotationView
    }
  
    return nil
  }
  
}

extension MapViewController: UINavigationBarDelegate {
  
  // This tell the navigation bar to extend under the status bar area
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
 
    return .TopAttached
  }
}











