//
//  ZYPhotoView.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

class ZYPhotoView: UIScrollView {

  lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = UIColor.darkGray
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  lazy var progressLayer: ZYProgressLayer = {
    let shapeLayer = ZYProgressLayer(frame: CGRect(x: 0, y: 0, width: 40, height: 40) )
    shapeLayer.isHidden = true
    return shapeLayer
  }()
  var item: ZYPhotoItem?
  fileprivate let _imageManager: ZYImageManager
  
  init(frame: CGRect,imageManager:ZYImageManager ) {
    self._imageManager = imageManager
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func setup(){
    self.backgroundColor = UIColor.clear
    self.bouncesZoom = true
    self.maximumZoomScale = CGFloat(ZYConstant.photoViewMaxScale)
    self.isMultipleTouchEnabled = true
    self.showsHorizontalScrollIndicator = true
    self.showsVerticalScrollIndicator = true
    self.delegate = self
    
    self.addSubview(imageView)
    self.resizeImageView()
    self.layer.addSublayer(progressLayer)
    progressLayer.position = CGPoint(x: frame.width/2, y: frame.height/2)
  }
	
  func setItem(_ item:ZYPhotoItem? , determinate:Bool){
    self.item = item
    if let item = item{
      if let image = item.image {
        imageView.image = image
        item.finished = true
        progressLayer.stopSpin()
        progressLayer.isHidden = true
        self.resizeImageView()
        return
      }
      progressLayer.startSpin()
      progressLayer.isHidden = false
      imageView.image = item.thunbImage
      imageView.kf.setImage(with:item.imageURL, placeholder: item.thunbImage, options: nil , progressBlock: nil, completionHandler: { [weak self] (image, err, cacheType, url) in
        guard let strongSelf = self else{ return }
        if err == nil {
          strongSelf.resizeImageView()
          strongSelf.progressLayer.stopSpin()
          strongSelf.progressLayer.isHidden = true
          strongSelf.item?.finished = true
        }else{
          print(err?.localizedDescription ?? "")
        }
      })
    }else{
      progressLayer.stopSpin()
      progressLayer.isHidden = true
      imageView.image = nil
    }
    self.resizeImageView()
  }
  
  /// 计算imageView显示位置
  func resizeImageView(){
    if let image = imageView.image {
      let imageSize = image.size
      let width = imageView.frame.width
      let height = width * (imageSize.height/imageSize.width)
      let rect  = CGRect(x: 0, y: 0, width: width, height: height)
      imageView.frame = rect
      
      // 如果图片特别长 只显示上半部分
      if height <= self.bounds.size.height {
        imageView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
      }else{
        imageView.center = CGPoint(x: bounds.size.width/2, y: height/2)
      }
      
    }else{
      let width = self.frame.width - 2*ZYConstant.photoViewPadding
      imageView.frame = CGRect(x: 0, y: 0, width: width, height: width*2/3)
      imageView.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    }
    self.contentSize = imageView.frame.size
  }
  
  func isScrollViewOnTopOrBottom()->Bool{
    let transition = self.panGestureRecognizer.translation(in: self)
    if transition.y > 0 && self.contentOffset.y <= 0{
      return true
    }
    let maxOffsetY = floor( self.contentSize.height - self.bounds.size.height )
    if transition.y < 0 && self.contentOffset.y >= maxOffsetY {
      return true
    }
    return false
  }
  
}



// MARK: - UIScrollViewDelegate,UIGestureRecognizerDelegate
extension ZYPhotoView: UIScrollViewDelegate,UIGestureRecognizerDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width)*0.5:0
    let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height)*0.5:0
    
    imageView.center = CGPoint(x: scrollView.contentSize.width*0.5+offsetX, y: scrollView.contentSize.height*0.5+offsetY)
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if gestureRecognizer == self.panGestureRecognizer {
      if gestureRecognizer.state == .possible {
        if isScrollViewOnTopOrBottom() {
          return false
        }
      }
    }
    return true
  }
  
}














