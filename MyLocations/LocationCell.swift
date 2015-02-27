//
//  LocationCell.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/22.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  @IBOutlet weak var photoImageView: UIImageView!

  // This method is invoked when UIKit loads the object from the storyboard
  override func awakeFromNib() {
    super.awakeFromNib()
  
    self.backgroundColor = UIColor.blackColor()
    self.descriptionLabel.textColor = UIColor.whiteColor()
    self.descriptionLabel.highlightedTextColor = descriptionLabel.textColor
    self.addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
    self.addressLabel.highlightedTextColor = addressLabel.textColor
    
    // Create a new UIView filled with a dark gray color. This new view is placed on top of the cell's background when the user eaps on the cell
    let selectionView = UIView(frame: CGRect.zeroRect)
    selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    self.selectedBackgroundView = selectionView
    
    // This make the image to a perfect circle
    photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
    photoImageView.clipsToBounds = true
    // 將separator 往左移，image間沒有separator
    separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    
    
    //descriptionLabel.backgroundColor = UIColor.blueColor()
    //addressLabel.backgroundColor = UIColor.redColor()
    // Initialization code
  }
  
  
  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
  func configureForLocation(location: Location) {

    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Description)"
    } else {
      descriptionLabel.text = location.locationDescription
    }
    
    if let placemark = location.placemark {
      var text = ""
      text.addText(placemark.subThoroughfare)
      text.addText(placemark.thoroughfare, withSeparator: " ")
      text.addText(placemark.locality, withSeparator: ", ")
      addressLabel.text = text
      
    } else {
      addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
    }
    
    photoImageView.image = imageForLocation(location)
    
    
  }
  
  func imageForLocation(location: Location) -> UIImage {
    if location.hasPhoto {
      if let image = location.photoImage {
        // scale down the images before putting them into the table view cell will speed up the processing
        return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
      }
    }
    // return empty placeholder image
    // upwrap the optional
    return UIImage(named: "No Photo")!
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if let sv = superview {
      descriptionLabel.frame.size.width = sv.frame.size.width - descriptionLabel.frame.origin.x - 10
      
      addressLabel.frame.size.width = sv.frame.size.width - addressLabel.frame.origin.x - 10
    }
  }

}
