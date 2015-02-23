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

  override func awakeFromNib() {
      super.awakeFromNib()
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
      addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare), \(placemark.locality)"
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
    return UIImage()
  }

}
