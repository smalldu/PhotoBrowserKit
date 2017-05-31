//
//  ZYPhotoBroswer.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit


protocol ZYPhotoBrowserDelegate: NSObjectProtocol {
  func zy_photoBrowser(_ browser:ZYPhotoBrowser,didSelect item:ZYPhotoItem, at index:Int)
}

class ZYPhotoBrowser: UIViewController {
  
  fileprivate lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    return scrollView
  }()
  
  fileprivate lazy var backgroundView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.alpha = 0
    return imageView
  }()
  
  
  /// 显示页码
  fileprivate lazy var pageLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()
  
  
  /// 当前页
  fileprivate var currentPage: Int
  fileprivate var photoItems: [ZYPhotoItem]
  fileprivate var visibleItemViews: [ZYPhotoView] = []
  
  weak var delegate: ZYPhotoBrowserDelegate?
  
  init(photoItems: [ZYPhotoItem] , selectedIndex index:Int) {
    self.currentPage = index
    self.photoItems = photoItems
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    layoutUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    willAppear()
  }
  
}


// MARK: - setup ui
extension ZYPhotoBrowser{

  func layoutUI(){
    // add backgroundview
    view.addSubview(backgroundView)
    
    // add scrollview
    var rect = view.bounds
    rect.origin.x = ZYConstant.photoViewPadding
    rect.size.width += 2*ZYConstant.photoViewPadding
    scrollView.frame = rect
    view.addSubview(scrollView)
    
    // add page label
    pageLabel.frame = CGRect(x: 0, y: rect.height - 40 , width: view.bounds.width , height: 20)
    configLabelWithPage(currentPage)
    view.addSubview(pageLabel)
    
    // setup other
    let contentSize = CGSize(width: rect.width * CGFloat(photoItems.count), height: rect.height)
    scrollView.contentSize = contentSize
    
    let contentOffset = CGPoint(x: scrollView.frame.width * CGFloat( currentPage ) , y: 0)
    scrollView.contentOffset = contentOffset
    if contentOffset.x == 0{
      self.scrollViewDidScroll(scrollView)
    }
  }
  
  func willAppear(){
    let item = self.photoItems[currentPage]
    let photoView = self.visibleItemViews.safeIndex(currentPage)
    
    
    
  }
  
}


// MARK: - some calculate
extension ZYPhotoBrowser {
  
  func configLabelWithPage(_ page: Int){
    pageLabel.text = "\(page+1) / \(photoItems.count)"
  }
  
}


// MARK: - UIScrollViewDelegate
extension ZYPhotoBrowser: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
  }
  
}

























