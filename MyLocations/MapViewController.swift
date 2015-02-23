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
        
        
        // TODO: reloading of the locations more efficient by not re-fetching the entire list of Location objects (page 218)
        if let dictionary = notification.userInfo {
          //println("*********inserted**********")
          println(dictionary["inserted"])
          //println("*********end with inserted**********")
          
          //println("*********deleted**********")
          println(dictionary["deleted"])
          //println("*********end with deleted**********")
          
          //println("*********updated**********")
          println(dictionary["updated"])
          //println("*********end of updated**********")
        }
        
        if self.isViewLoaded() {
          self.updateLocations()
        }
      }
    }
  }
  
  override func viewDidLoad() {
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
    
    locations = foundObjects as [Location]
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
      let navigationController = segue.destinationViewController as UINavigationController
    
      let controller = navigationController.topViewController as LocationDetailsViewController
    
      controller.managedObjectContext = managedObjectContext
      
      let button = sender as UIButton
      
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
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKPinAnnotationView!
      
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
  
        // 3
        annotationView.enabled = true
        annotationView.canShowCallout = true
        annotationView.animatesDrop = false
        annotationView.pinColor = .Green
        
        // 4 Implement target-action pattern manually
        let rightButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        
        rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
        
        annotationView.rightCalloutAccessoryView = rightButton
      
      } else {
        annotationView.annotation = annotation
      }
  
      // 5
      let button = annotationView.rightCalloutAccessoryView as UIButton
      if let index = find(locations, annotation as Location) {
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











