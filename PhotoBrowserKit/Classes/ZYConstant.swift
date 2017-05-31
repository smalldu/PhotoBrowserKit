//
//  ZYConstant.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

extension Array {
  public func zy_safeIndex(_ i : Int) -> Element? {
    if i < self.count && i >= 0 {
      return self[i]
    } else {
      return nil
    }
  }
}
struct ZYConstant {
  static let photoViewPadding: CGFloat = 10
  static let photoViewMaxScale: Int = 3
  static let springAnimationDuration: TimeInterval = 0.3
  
}


