//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore  // Core Animation
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  
  
  @IBOutlet weak var latitudeTextLabel: UILabel!
  @IBOutlet weak var longitudeTextLabel: UILabel!
  
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
  var managedObjectContext: NSManagedObjectContext!
  
  var logoVisible = false
  
  var soundID: SystemSoundID = 0
  
  lazy var logoButton: UIButton = {
    let button = UIButton.buttonWithType(.Custom) as UIButton
    button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
    button.sizeToFit()
    button.addTarget(self, action: Selector("getLocation"), forControlEvents: .TouchUpInside)

    button.center.x = CGRectGetMidX(self.view.bounds)
    button.center.y = 220
    
    return button
  }()
  
  

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetButton()
    loadSoundEffect("Sound.caf")
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
    //println("In stopLocationManger")
    if self.updatingLocation {
      //println("self.updatingLocation = true")
      
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
      //println("before stopLocationManager")
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
      
      latitudeTextLabel.hidden = false
      longitudeTextLabel.hidden = false
      
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
        //statusMessage = "Tap 'Get My Location' to Start"
        statusMessage = ""
        showLogoView()
      }

      self.messageLabel.text = statusMessage
      
      latitudeTextLabel.hidden = true
      longitudeTextLabel.hidden = true
    }
  }
  
  func configureGetButton() {
    
    let spinnerTag = 1000
    
    if updatingLocation {
      getButton.setTitle("stop", forState: .Normal)
      
      if view.viewWithTag(spinnerTag) == nil {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
        
        spinner.center = messageLabel.center
        spinner.center.y += spinner.bounds.size.height/2 + 15
        spinner.startAnimating()
        spinner.tag = spinnerTag
        containerView.addSubview(spinner)
      }
      
    } else {
    
      getButton.setTitle("Get My Location", forState: .Normal)
      
      if let spinner = view.viewWithTag(spinnerTag){
        spinner.removeFromSuperview()
      }
      
    }
  }
  
  
  

  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    
    var line1 = ""
    line1.addText(placemark.subThoroughfare)
    line1.addText(placemark.thoroughfare, withSeparator: " ")
    
    var line2 = ""
    line2.addText(placemark.locality)
    line2.addText(placemark.administrativeArea, withSeparator: " ")
    line2.addText(placemark.postalCode, withSeparator: " ")
    
    if line1.isEmpty {
      return line2 + "\n "
    } else {
      return line1 + "\n" + line2
    }
    
    
    /*
    return
      "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" +
        "\(placemark.locality) \(placemark.administrativeArea) " +
    "\(placemark.postalCode)"
    */
  
  }
  

// MARK: - Logo View
  func showLogoView() {
    if !logoVisible {
      logoVisible = true
      containerView.hidden = true
      view.addSubview(logoButton)
    }
  }
  
  func hideLogoView() {
    
    if !logoVisible { return }
    
    logoVisible = false
    containerView.hidden = false
    
    
    containerView.center.x = view.bounds.size.width * 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    
    let centerX = CGRectGetMidX(view.bounds)
    
    let panelMover = CABasicAnimation(keyPath: "position")
    panelMover.removedOnCompletion = false
    panelMover.fillMode = kCAFillModeBackwards
    panelMover.duration = 0.6
    panelMover.fromValue = NSValue(CGPoint: containerView.center)
    panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y) )
    panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    panelMover.delegate = self
    
    containerView.layer.addAnimation(panelMover, forKey: "panelMover")
    
    let logoMover = CABasicAnimation(keyPath: "position")
    logoMover.removedOnCompletion = false
    logoMover.fillMode = kCAFillModeForwards
    logoMover.duration = 0.5
    logoMover.fromValue = NSValue(CGPoint: logoButton.center)
    logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y) )
    logoMover.timingFunction = CAMediaTimingFunction( name: kCAMediaTimingFunctionEaseIn)
    logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
    
    let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
    logoRotator.removedOnCompletion = false
    logoRotator.fillMode = kCAFillModeForwards
    logoRotator.duration = 0.5
    logoRotator.fromValue = 0.0
    logoRotator.toValue = -2 * M_PI
    logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    
    logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
    
    //logoButton.removeFromSuperview()
  }
  
// MARK: - animation delegate
  
  // This cleans up after the animations and removes the logo button
  override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
    containerView.layer.removeAllAnimations()
    containerView.center.x = view.bounds.size.width / 2
    containerView.center.y = 40 + containerView.bounds.size.height / 2
    
    logoButton.layer.removeAllAnimations()
    logoButton.removeFromSuperview()
  }
  
  
// MARK: - CLLocationManagerDelegate
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

      if !performingReverseGeocoding {
        println("*** Going to geocode")
        
        self.performingReverseGeocoding = true
        self.geocoder.reverseGeocodeLocation(self.location, completionHandler: {
          placemarks, error in
          
          //println("*** Found placemarks: \(placemarks), error: \(error) ")
          
          self.lastGeocodingError = error
          if error == nil && !placemarks.isEmpty {
            
            if self.placemark == nil {
              println("FIRST TIME!")
              self.playSoundEffect()
            }
            
            self.placemark = placemarks.last as? CLPlacemark
          } else {
            self.placemark = nil
          }
          
          self.performingReverseGeocoding = false
          self.updateLabels()
          
        })
      }
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
    
    if logoVisible {
      hideLogoView()
    }
    
    
    if self.updatingLocation {
      stopLocationManager()
    } else {
      // Clear out the old location and error objects before starting looking for a new location
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
      
      controller.managedObjectContext = self.managedObjectContext
      
    }
    
  }
  
// MARK: - Sound Eddect
  func loadSoundEffect(name: String) {
  
    if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
    
      let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)
      if fileURL == nil {
        println("NSURL is nil for path: \(path)")
        return
      }
      
      // reference to that object in the soundID instance variable
      let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
      if Int(error) != kAudioServicesNoError {
        println("Error code \(error) loading sound at path: \(path)")
      }
    }
    
  }
  
  func unloadSoundEffect() {
    AudioServicesDisposeSystemSoundID(soundID)
    soundID = 0
  }
  
  func playSoundEffect() {
    AudioServicesPlaySystemSound(soundID)
  }
  

}

