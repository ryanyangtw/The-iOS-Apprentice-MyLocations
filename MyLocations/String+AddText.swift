//
//  String+AddText.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/24.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

//import Foundation

extension String {
  // mutating: this method can only be used on strings that are made with var
  mutating func addText(text: String?, withSeparator separator: String = "") {

    if let text = text {
      if !self.isEmpty {
        self += separator
      }
      self += text
    }
  }
}
