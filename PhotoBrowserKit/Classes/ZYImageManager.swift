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

  func setImage(_ imageView:UIImageView?,imageUrl:URL?,placeHoder:UIImage?,complete:@escaping ((_ image:UIImage? , _ url:URL?)->())) {
    imageView?.kf.setImage(with: imageUrl, placeholder: placeHoder, options: nil , progressBlock: { (receivedSize, expectedSize) in
      
    }, completionHandler: { (image, error , cacheType , url) in
      complete(image, url)
    })
  }
  
  func imageFromMemoryForURL(_ url:URL) -> Image?{
    return KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url.absoluteString)
  }
  
}
