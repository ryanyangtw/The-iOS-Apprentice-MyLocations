//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/22.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  //var locations = [Location]()
 
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    //let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    //fetchRequest.sortDescriptors = [sortDescriptor]
    let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
    let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
    
    
    // How many objects will be fetched at a time
    fetchRequest.fetchBatchSize = 20
    
    let fetchedResultsController = NSFetchedResultsController(
    fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
    
    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  deinit {
    fetchedResultsController.delegate = nil
  }
  
  
// MARK: - Controller Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    performFetch()
    
    navigationItem.rightBarButtonItem = editButtonItem()
    
    /*
    // NSFetchRequest is the object that describes which objects you're going to fetch from the data store
    let fetchRequest = NSFetchRequest()
    
    // 2
    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
    fetchRequest.entity = entity
    
    // 3
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // 4
    var error: NSError?
    let foundObjects = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
    
    if foundObjects == nil {
      fatalCoreDataError(error)
      return
    }
    
    // 5
    self.locations = foundObjects as [Location]
    */
  }
  
  func performFetch() {
    var error: NSError?
    if !fetchedResultsController.performFetch(&error) {
      fatalCoreDataError(error)
    }
  }
  
// MARK: - UITableView DataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    
    return sectionInfo.name
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    let sectionInfo =  fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    
    return sectionInfo.numberOfObjects
    //return locations.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
    let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as LocationCell
    
    //let location = locations[indexPath.row]
    let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
    
    cell.configureForLocation(location)
  
    /* This is the older version
    let descriptionLabel = cell.viewWithTag(100) as UILabel
    descriptionLabel.text = location.locationDescription
    
    let addressLabel = cell.viewWithTag(101) as UILabel
    if let placemark = location.placemark {
      addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," + "\(placemark.locality)"
    } else {
      addressLabel.text = ""
    }
    */
    
    
    return cell
  
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
      
      location.removePhotoFile()
      managedObjectContext.deleteObject(location)
      
      var error: NSError?
      if !managedObjectContext.save(&error) {
        fatalCoreDataError(error)
      }
    }
  
  }
  
  
// MARK: - TableView Dlegate
  
  
  
// MARK: - Prepare For Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if segue.identifier == "EditLocation" {

      let navigationController = segue.destinationViewController as UINavigationController
      
      let controller = navigationController.topViewController as LocationDetailsViewController
      
      controller.managedObjectContext = self.managedObjectContext
      

      if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {  // cast sender to UITableViewCell
        //let location = locations[indexPath.row]
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
        controller.locationToEdit = location
      }
      
    }
  }
  
}

// MARK: - NSFetchedResultsController Delegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    println("*** contollerWillChangeContent")
    
    tableView.beginUpdates()
  }
  
  func controller(controller: NSFetchedResultsController,
                  didChangeObject anyObject: AnyObject,
                  atIndexPath indexPath: NSIndexPath?,
                  forChangeType type: NSFetchedResultsChangeType,
                  newIndexPath: NSIndexPath?) {
                    
    switch type {
      case .Insert:
        println("*** NSFetchResultsChangeInsert (object)")
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
      
      case .Delete:
        println("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      
      case .Update:
        //println("indexPath.row: \(indexPath!.row)")
        //println("indexPath.section: \(indexPath!.section)")
        println("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
          let location = controller.objectAtIndexPath(indexPath!) as Location
          cell.configureForLocation(location)
        }
      
      case .Move:
        println("*** NSFetchedResultsChangeMove (object)")
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
  
    switch type {
      case .Insert:
        println("*** NSFetchedResultsChangeInsert (section)")
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      
      case .Delete:
        println("*** NSFetchedResultsChangeDelete (section) ")
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      
      case .Update:
        println("*** NSFetchedResultsChangeUpdate (section)")
      
      case .Move:
        println(" *** NSFethchedResultsChangeMove (section)")
    }
  
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    println("*** controllerDidChangeContent")
    tableView.endUpdates()
  }
  
}
