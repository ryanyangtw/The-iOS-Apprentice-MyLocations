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
  
  

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
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
  
  func stopLocationManager() {
    if self.updatingLocation {
      self.locationManager.stopUpdatingLocation()
      self.locationManager.delegate = nil
      self.updatingLocation = false
    }
  
  }
  
  
//MARK: - Update UI
  func updateLabels() {
    if let location = self.location {
      self.latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      
      self.longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      
      self.tagButton.hidden = false
      self.messageLabel.text = ""
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
  
  
  
//MARK: - CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("didFailWithError \(error)")
    
    // rawValue: Convert the enum name back to integer
    if error.code == CLError.LocationUnknown.rawValue {
      return
    }
    
    self.lastLocationError = error
    
    stopLocationManager()
    updateLabels()
  
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
    let newLocation = locations.last as CLLocation
    println("didUpdateLocations \(newLocation)")
    
    self.location = newLocation
    updateLabels()
  
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
    
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    self.locationManager.startUpdatingLocation()
  
  }
  

}

