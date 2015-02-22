//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/19.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .MediumStyle
  formatter.timeStyle = .ShortStyle
  return formatter
}()


class LocationDetailsViewController: UITableViewController {


  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var descriptionText = ""
  var categoryName = "No Category"
  
  var managedObjectContext: NSManagedObjectContext!
  
  var date = NSDate()
  
  var locationToEdit: Location? {
    didSet {
      if let location = locationToEdit {
        descriptionText = location.locationDescription
        categoryName = location.category
        date = location.date
        coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        placemark = location.placemark
      }
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let location = locationToEdit {
      title = "Edit Location"
    }
    
    self.descriptionTextView.text = self.descriptionText
    self.categoryLabel.text = self.categoryName
    
    self.latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    
    self.longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    if let placemark = self.placemark {
      self.addressLabel.text = stringFromPlacemark(placemark)
    } else {
      self.addressLabel.text = "No Address Found"
    }
    
    self.dateLabel.text = formatDate(date)
    
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:") )
    gestureRecognizer.cancelsTouchesInView = false
    self.tableView.addGestureRecognizer(gestureRecognizer)
  
  }
  
  
  func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
    
    let point = gestureRecognizer.locationInView(tableView)
    let indexPath = tableView.indexPathForRowAtPoint(point)
    // don’t want to hide the keyboard if the user tapped in the row with the description text view!
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
     return
    }
    
    self.descriptionTextView.resignFirstResponder()
    
  
  }
  
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    return "\(placemark.subThoroughfare) \(placemark.thoroughfare), " + "\(placemark.locality), " + "\(placemark.administrativeArea) \(placemark.postalCode), " + "\(placemark.country)"
    
  }
  
  func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }

// MARK: - UITableViewDelegate
  
  // frame,bounds has ( origin(x,y), size(width,height) )
  // frame: The rame idscrives the position and size of a view in its parent view. The frame describe the outside
  // bounds: The bounds describe the inside
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 && indexPath.row == 0 {
      return 88
    } else if indexPath.section == 2 && indexPath.row == 2 {
      // 1
      self.addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
      
      // 2 Removed any spare space to the right and bottom of the label
        self.addressLabel.sizeToFit()

      // 3
      self.addressLabel.frame.origin.x = view.bounds.size.width - self.addressLabel.frame.size.width - 15
  
      
      // 4
      return self.addressLabel.frame.size.height + 20
      
    } else {
      return 44
    
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    
    if indexPath.section == 0 || indexPath.section == 1{
      return indexPath
    } else {
      return nil
    }

  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 && indexPath.row == 0{
      self.descriptionTextView.becomeFirstResponder()
    }
  }

  
// MARK: - Action

  @IBAction func done() {
    //println("Desceiption: '\(self.descriptionText)' ")
    let hudView = HudView.hudInView(navigationController!.view, animated: true)
    
    
    var location: Location
  
    if let temp = locationToEdit {
      hudView.text = "Updated"
      location = temp
    } else {
      hudView.text = "Tagged"
      
      // 1 Create a new Location object. ask the NSEntityDescription class to insert a new object for your entity into the managed object context
      location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext) as Location
    }
    
    
    // 2
    location.locationDescription = self.descriptionText
    location.category = self.categoryName
    location.latitude = self.coordinate.latitude
    location.longitude = self.coordinate.longitude
    location.date = self.date
    location.placemark = self.placemark
    
    // 3
    var error: NSError?
    if !managedObjectContext.save(&error) {
      fatalCoreDataError(error)
      return
    }
    
    // Abstract GCD
    // trailing closure syntax
    afterDelay(0.6) {
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    //dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func cancel() {
    dismissViewControllerAnimated(true , completion: nil)
  }
  
  @IBAction func categoryPickerDidPickCategory( segue: UIStoryboardSegue) {
    //println("in categoryPickerDidPickCategory")
    let controller = segue.sourceViewController as CategoryPickerViewController
    self.categoryName = controller.selectedCategoryName
    self.categoryLabel.text = self.categoryName
  
  }

  
// MARK: - Preoare for Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickCategory" {
      
      let controller = segue.destinationViewController as CategoryPickerViewController
      controller.selectedCategoryName = self.categoryName
    }
  
  }
  
}

// MARK: - UITextView Delegate
// Extension: it keeps the responsibilities separate
extension LocationDetailsViewController: UITextViewDelegate {

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
    self.descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
    
    return true
  }

  func textViewDidEndEditing(textView: UITextView) {
    self.descriptionText = textView.text
  }
}

