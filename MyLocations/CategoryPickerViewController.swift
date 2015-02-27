//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/20.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
  
  var selectedCategoryName = ""

  let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Builder",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"]
  
  var selectedIndexPath = NSIndexPath()
  
// MARK: - Controller Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = UIColor.blackColor()
    tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
    tableView.indicatorStyle = .White
  }
  
  
  // MARK: - UITableView DataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
    return categories.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
    
    let categoryName = self.categories[indexPath.row]
    cell.textLabel!.text = categoryName
    
    if categoryName == self.selectedCategoryName {
      cell.accessoryType = .Checkmark
      self.selectedIndexPath = indexPath
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }
  
  // MARK: - UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  
    if indexPath.row != self.selectedIndexPath.row {
      if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
        newCell.accessoryType = .Checkmark
      }
    }
    
    if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
      oldCell.accessoryType = .None
    }
    //println("categories[indexPath.row]: \(categories[indexPath.row])")
    //self.selectedCategoryName = categories[indexPath.row]
    selectedIndexPath = indexPath
  
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    cell.backgroundColor = UIColor.blackColor()
    if let textLabel = cell.textLabel {
      textLabel.textColor = UIColor.whiteColor()
      textLabel.highlightedTextColor = textLabel.textColor
    }
    
    let selectionView = UIView(frame: CGRect.zeroRect)
    selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    cell.selectedBackgroundView = selectionView
  
  }
  
// MARK: - Prepare for Segue
  
  
  // Unwind Segue
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickedCategory" {
      let cell = sender as UITableViewCell
      if let indexPath = tableView.indexPathForCell(cell) {
        //println("In unwind segue, selfectedCaetgoryName: \(self.selectedCategoryName) ")
        
        // selectedCategoryName should be setting in prepareForSegue instead of tableView(didSelectRowAtIndexPath. Because prepareForSegue is execuated before tableView(didSelectRowAtIndexPath) and categoryPickerDidPickCategory action in LocationDetailViewController will not get value.
        self.selectedCategoryName = self.categories[indexPath.row]
      }
  
    }
  }
  
  
  
  
  

}