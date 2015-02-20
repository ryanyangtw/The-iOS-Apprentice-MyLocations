//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: NSError?
  
  // Geocoding
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: NSError?
  
  var timer: NSTimer?
  
  

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetButton()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
//MARK: - General Method
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
    
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    
    alert.addAction(okAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      self.locationManager.startUpdatingLocation()
      self.updatingLocation = true
      
      self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
    }
  }
  
  func stopLocationManager() {
    if self.updatingLocation {
      
      if let timer = self.timer {
        timer.invalidate()
      }
      
      self.locationManager.stopUpdatingLocation()
      self.locationManager.delegate = nil
      self.updatingLocation = false
    }
  
  }
  
  func didTimeOut() {
    println("*** Time out")
    
    if self.location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      
      updateLabels()
      configureGetButton()
    
    }
  }

  
  
//MARK: - Update UI
  func updateLabels() {
    if let location = self.location {
      self.latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      
      self.longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      
      self.tagButton.hidden = false
      self.messageLabel.text = ""
      
      if let placemark = self.placemark {
        self.addressLabel.text = stringFromPlacemark(placemark)
      } else if self.performingReverseGeocoding {
        self.addressLabel.text = "Searching for Address....."
      } else if self.lastGeocodingError != nil {
        self.addressLabel.text = "Error Finding Address"
      } else {
        self.addressLabel.text = "No Address Found"
      }
      
      
    } else {
      
      self.latitudeLabel.text = ""
      self.longitudeLabel.text = ""
      self.addressLabel.text = ""
      self.tagButton.hidden = true
      
      var statusMessage: String
      

      if let error = self.lastLocationError {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
        
          statusMessage  = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if self.updatingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }

      self.messageLabel.text = statusMessage
    }
  }
  
  func configureGetButton() {
    if self.updatingLocation {
      self.getButton.setTitle("Stop", forState: .Normal)
    } else {
      self.getButton.setTitle("Get My Location", forState: .Normal)
    }
  }
  
  
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    
    /*
    println("subThoroughfare : \(placemark.subThoroughfare)")
    println("thoroughfare : \(placemark.thoroughfare)")
    println("locality : \(placemark.locality)")
    println("subThorougadministrativeAreahfare : \(placemark.administrativeArea)")
    println("postalCode : \(placemark.postalCode)")
    */
    
    return
      "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" +
        "\(placemark.locality) \(placemark.administrativeArea) " +
    "\(placemark.postalCode)"
    
  
  }
  
  
  
//MARK: - CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("didFailWithError \(error)")
    
    // rawValue: Convert the enum name back to integer
    if error.code == CLError.LocationUnknown.rawValue {
      //println("error.code == CLError.LocationUnknown.rawValue")
      return
    }
    
    self.lastLocationError = error
    
    stopLocationManager()
    updateLabels()
    configureGetButton()
  
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let newLocation = locations.last as CLLocation
    println("didUpdateLocations \(newLocation)")
    
    
    // 1
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    // 2
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    var distance = CLLocationDistance(DBL_MAX)
    if let location = self.location {
      distance = newLocation.distanceFromLocation(location)
    }
    
    // 3 If this is the very first location reading or the new location is more accurate than the previous reading, go on.
    if self.location == nil || self.location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      
      // 4 
      self.lastLocationError = nil
      self.location = newLocation
      updateLabels()
      
      // 5
      if newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy {
        println("*** We're done!")
        stopLocationManager()
        configureGetButton()
        
        if distance > 0 {
          // Force the geocoding to be done for this final coordinate
          self.performingReverseGeocoding = false
        }
      }

    }
    

    
    if !performingReverseGeocoding {
      println("*** Going to geocode")
      
      self.performingReverseGeocoding = true
      self.geocoder.reverseGeocodeLocation(self.location, completionHandler: {
        placemarks, error in
        
        //println("*** Found placemarks: \(placemarks), error: \(error) ")
        
        self.lastGeocodingError = error
        if error == nil && !placemarks.isEmpty {
          self.placemark = placemarks.last as? CLPlacemark
        } else {
          self.placemark = nil
        }
        
        self.performingReverseGeocoding = false
        self.updateLabels()
        
      })
    } else if distance < 1.0 {
      
      let timeInterval = newLocation.timestamp.timeIntervalSinceDate(self.location!.timestamp)
      // 若10秒內都沒有更精確的地理位置，則強制結束
      if timeInterval > 10 {
        println("*** Force done!")
        stopLocationManager()
        updateLabels()
        configureGetButton()
      }
    }
    
  }

//MARK: - Action
  
  @IBAction func getLocation() {

    let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
    
    if authStatus == .NotDetermined {
      self.locationManager.requestWhenInUseAuthorization()
      return
    }
    
    // Shows the alert if the authorization status is denied or restricted
    if authStatus == .Denied || authStatus == .Restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    
    if self.updatingLocation {
      stopLocationManager()
    } else {
      // Clear out the old location ans error objects before starting looking for a new location
      self.location = nil
      self.lastLocationError = nil
      self.placemark = nil
      self.lastGeocodingError = nil
      startLocationManager()
    }
    
    updateLabels()
    configureGetButton()
  
  }
  

//MARK: - Prepare for segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
    if segue.identifier == "TagLocation" {
      let navigationController = segue.destinationViewController as UINavigationController
      
      let controller = navigationController.topViewController as LocationDetailsViewController
      
      controller.coordinate = self.location!.coordinate
      controller.placemark = self.placemark
      
    }
    
  }
  

}

