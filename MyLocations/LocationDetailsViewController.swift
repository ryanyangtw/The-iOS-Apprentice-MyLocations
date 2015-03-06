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
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var addPhotoLabel: UILabel!
  

  
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var descriptionText = ""
  var categoryName = "No Category"
  
  var managedObjectContext: NSManagedObjectContext!
  
  var date = NSDate()
  
  var image: UIImage? {
    didSet {
      if let image = self.image {
        showImage(image)
      }
    }
  }
  
  var observer: AnyObject!
  
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

  deinit {
    //println("*** deinit \(self) ")
    NSNotificationCenter.defaultCenter().removeObserver(self.observer)
  }
  
  override func viewDidLoad() {
    println("fuckiing viewDidLoad")
    super.viewDidLoad()
    
    if let location = locationToEdit {
      title = "Edit Location"
      if location.hasPhoto {
        if let image = location.photoImage {
          showImage(image)
          
        }
      }
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
    
    listenForBackgroundNotification()
    
    
    tableView.backgroundColor = UIColor.blackColor()
    tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
    tableView.indicatorStyle = .White
    
    descriptionTextView.textColor = UIColor.whiteColor()
    descriptionTextView.backgroundColor = UIColor.blackColor()
    
    addPhotoLabel.textColor = UIColor.whiteColor()
    addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
    
    addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
    addressLabel.highlightedTextColor = addressLabel.textColor
  
  }
  
  
// MARK: - General Method
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
    
    var line = ""
    line.addText(placemark.subThoroughfare)
    line.addText(placemark.thoroughfare, withSeparator: " ")
    line.addText(placemark.locality, withSeparator: ", ")
    line.addText(placemark.administrativeArea, withSeparator: ", ")
    line.addText(placemark.postalCode, withSeparator: " ")
    line.addText(placemark.country, withSeparator: ", ")
    
    return line
    //return "\(placemark.subThoroughfare) \(placemark.thoroughfare), " + "\(placemark.locality), " + "\(placemark.administrativeArea) \(placemark.postalCode), " + "\(placemark.country)"
    
  }
  
  func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }
  
  func showImage(image: UIImage) {

    imageView.image = image
    imageView.hidden = false

    // use frame and center to position the view in hierarchy
    imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
    addPhotoLabel.hidden = true
  }
  
  func listenForBackgroundNotification() {
    println("In listenForBackgroundNotification")
    self.observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] notification in
      
        if let strongSelf = self {
                //println("self: \(self)")
          if strongSelf.presentedViewController != nil {
            strongSelf.dismissViewControllerAnimated(false, completion: nil)
          }
        
          strongSelf.descriptionTextView.resignFirstResponder()
        }
      }
  }
  
  

// MARK: - UITableView Delegate
  
  // frame,bounds has ( origin(x,y), size(width,height) )
  // frame: The frame describes the position and size of a view in its parent view. The frame describe the outside
  // bounds: The bounds describe the inside
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    switch (indexPath.section, indexPath.row) {
      
      case (0, 0):
        return 88
      
      case (1, _):
          return imageView.hidden ? 44 : 280
        
      case (2, 2):
        // 1
        self.addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
        
        // 2 Removed any spare space to the right and bottom of the label
        self.addressLabel.sizeToFit()
        
        // 3
        self.addressLabel.frame.origin.x = view.bounds.size.width - self.addressLabel.frame.size.width - 15
        
        // 4
        return self.addressLabel.frame.size.height + 20
        
      default:
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
    } else if indexPath.section == 1 && indexPath.row == 0{
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      pickPhoto()
      //choosePhotoFromLibrary()
      //takePhotoWithCamera()
    }
  }
  
  // "willDidplayCell" is called before a cell become visisble. Here you can do somw last-,omute customizations on the cell and its contents
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   
    cell.backgroundColor = UIColor.blackColor()
    
    // textLabel and detailLabel could only use the built-in cell types
    if let textLabel = cell.textLabel {
      textLabel.textColor = UIColor.whiteColor()
      textLabel.highlightedTextColor = textLabel.textColor
    }
    
    if let detailLabel = cell.detailTextLabel {
      detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
      detailLabel.highlightedTextColor = detailLabel.textColor
    }
    
    let selectionView = UIView(frame: CGRect.zeroRect)
    selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    cell.selectedBackgroundView = selectionView
    
    
    if indexPath.row == 2 {
      let addressLabel = cell.viewWithTag(100) as UILabel
      addressLabel.textColor = UIColor.whiteColor()
      
      // 被點擊時顯示的顏色
      //addressLabel.highlighted = true
      //addressLabel.highlightedTextColor = UIColor.blueColor()
      addressLabel.highlightedTextColor = UIColor.whiteColor()
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
      
      location.photoID = nil
    }
    
    
    // 2
    location.locationDescription = self.descriptionText
    location.category = self.categoryName
    location.latitude = self.coordinate.latitude
    location.longitude = self.coordinate.longitude
    location.date = self.date
    location.placemark = self.placemark
    
    
    if let image = self.image {
      
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID()
      }

      // convert the UIImage into the JPEG format and return NSData object
      let data = UIImageJPEGRepresentation(image, 0.5)
      // 3
      var error: NSError?
      if !data.writeToFile(location.photoPath, options: .DataWritingAtomic, error: &error) {
        println("Error writing file: \(error)")
      }
    }
    
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


// MARK: - UIImagePickerController (All of codes about Image picker)

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func takePhotoWithCamera() {
    //let imagePicker = UIImagePickerController()

    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .Camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func choosePhotoFromLibrary() {
    //let imagePicker = UIImagePickerController()
    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .PhotoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func pickPhoto() {
    // isSourceTypeAvailable(): check whether where's a camera present
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  
  func showPhotoMenu() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera()})
    alertController.addAction(takePhotoAction)
    
    let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary()})
    alertController.addAction(chooseFromLibraryAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }

// MARK: - UIImagePickerController Delegate
  
  // This is the method that gets callled when the user has selected a photo in the image picker
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    // Exercise p.229: rewite the logic to use a didSet property opserver on the image instance variable (p.229)
    self.image = info[UIImagePickerControllerEditedImage] as UIImage?
    
    // This code was replaced with a property observer utilizing a didSet block for variable, image
    /*
    if let image = self.image {
      showImage(image)
    }
    */
    
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
  
    dismissViewControllerAnimated(true, completion: nil)
  }

}



