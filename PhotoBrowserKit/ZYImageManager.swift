//
//  ZYImageManager.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit
import Kingfisher

class ZYImageManager: NSObject {

  func setImage(_ imageView:UIImageView?,imageUrl:URL?,placeHoder:UIImage?) {
    
    
    
  }
  
  
  func cancelImageRequestForUrl(_ url:URL) -> Image?{
    return ImageCache.default.retrieveImageInDiskCache(forKey: url.absoluteString)
  }
  
}
