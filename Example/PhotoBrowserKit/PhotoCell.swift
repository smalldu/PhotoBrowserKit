//
//  PhotoCell.swift
//  PhotoBrowserKit
//
//  Created by duzhe on 2017/5/31.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet weak var imageView:UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
  }
  
}
