//
//  ZYPhotoBroswer.swift
//  PhotoBrowserKit
//
//  Created by Zoey Shi on 2017/5/29.
//  Copyright © 2017年 Zoey Shi. All rights reserved.
//

import UIKit

public protocol ZYPhotoBrowserDelegate: NSObjectProtocol {
  func zy_photoBrowser(_ browser:ZYPhotoBrowser,didSelect item:ZYPhotoItem, at index:Int)
}


public enum ZYPageStyle {
  case dot
  case num
}

public class ZYPhotoBrowser: UIViewController {
  
  fileprivate lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    return scrollView
  }()
  
  /// 显示页码
  fileprivate lazy var pageLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()
  
  fileprivate lazy var pageControl: UIPageControl = {
    let pager = UIPageControl()
    return pager
  }()
  
  fileprivate lazy var saveBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("保存", for: .normal )
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    btn.layer.borderColor = UIColor.white.cgColor
    btn.layer.borderWidth = 0.5
    btn.addTarget(self, action: #selector(saveToPhoto), for: .touchUpInside )
    return btn
  }()
  
  fileprivate lazy var _imageManager = ZYImageManager()
  
  /// 当前页
  fileprivate var currentPage: Int
  fileprivate var photoItems: [ZYPhotoItem]
  fileprivate var visibleItemViews: [ZYPhotoView] = []
  fileprivate var reusableItemViews: [ZYPhotoView] = []
  fileprivate var _presented = false
  fileprivate var _startLocation = CGPoint.zero
  
  public var style: ZYPageStyle = .num
  public weak var delegate: ZYPhotoBrowserDelegate?
  
  public init(photoItems: [ZYPhotoItem] , selectedIndex index:Int) {
    self.currentPage = index
    self.photoItems = photoItems
    super.init(nibName: nil, bundle: nil)
    self.modalPresentationStyle = .custom
    self.modalTransitionStyle = .coverVertical
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    layoutUI()
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    willAppear()
  }
  
}


// MARK: - setup ui
extension ZYPhotoBrowser{

  func layoutUI(){
    self.view.backgroundColor = UIColor.clear
    
    // add scrollview
    var rect = view.bounds
    rect.origin.x -= ZYConstant.photoViewPadding
    rect.size.width += 2*ZYConstant.photoViewPadding
    scrollView.frame = rect
    view.addSubview(scrollView)
    
    if style == .num {
      // add page label
      pageLabel.frame = CGRect(x: 0, y: rect.height - 40 , width: view.bounds.width , height: 20)
      configLabelWithPage(currentPage)
      view.addSubview(pageLabel)
    }else{
      pageControl.frame = CGRect(x: 0, y: rect.height - 40 , width: view.bounds.width , height: 20)
      pageControl.numberOfPages = photoItems.count
      configLabelWithPage(currentPage)
      view.addSubview(pageControl)
    }
    
    // setup other
    let contentSize = CGSize(width: rect.width * CGFloat(photoItems.count), height: rect.height)
    scrollView.contentSize = contentSize
    
    setupGestureRecognize()
    let contentOffset = CGPoint(x: scrollView.frame.width * CGFloat( currentPage ) , y: 0)
    scrollView.setContentOffset(contentOffset, animated: false)
    if contentOffset.x == 0{
      self.scrollViewDidScroll(scrollView)
    }
    
    self.view.addSubview(saveBtn)
    saveBtn.frame = CGRect(x: ZYConstant.sw - 40  , y: 30 , width: 35 , height: 20 )
    saveBtn.alpha = 0.8
  }
  
  func willAppear(){
    let item = self.photoItems.zy_safeIndex(currentPage)
    let photoView = self.photoViewForPage(currentPage)
    if let url = item?.imageURL{
      if let _ = _imageManager.imageFromMemoryForURL(url) {
        photoView?.setItem(item, determinate: true)
      }else{
        photoView?.imageView.image = item?.thunbImage
        photoView?.resizeImageView()
      }
    }
    
    guard let sitem = item   else { return }
    guard let sphotoView = photoView else { return }
    let endRect = sphotoView.imageView.frame
    var sourceRect :CGRect = CGRect.zero
    
    if let superView = sitem.sourceView?.superview {
      sourceRect = superView.convert(sitem.sourceView?.frame ?? CGRect.zero, to: sphotoView)
      sphotoView.imageView.frame = sourceRect
    }
    // 动画
    UIView.animate(withDuration: ZYConstant.springAnimationDuration , delay: 0, animations: {
      sphotoView.imageView.frame = endRect
      self.view.backgroundColor = UIColor.black
    }) { (b) in
      sphotoView.setItem(sitem, determinate: true)
      self._presented = true
      UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
    }
  }
  
  public func showFromViewController(_ vc:UIViewController){
    vc.present(self, animated: false, completion: nil)
  }
  
  func saveToPhoto(){
    let photoView = self.photoViewForPage(currentPage)
    if let image = photoView?.imageView.image {
      
      // 保存到相册
      UIImageWriteToSavedPhotosAlbum(image, self, #selector(ZYPhotoBrowser.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
  }
  
  // 保存相册的回调 有可能失败
  func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    if let _ = error {
      print("保存失败")
      
    } else {
      print("保存成功")
      ZYTip.shared.showWith(title: "保存相册成功")
    }
  }
}


// MARK: - some calculate
extension ZYPhotoBrowser {
  func configLabelWithPage(_ page: Int){
    if style == .num {
      pageLabel.text = "\(page+1) / \(photoItems.count)"
    }else{
      pageControl.currentPage = page
    }
  }
  /// 更新缓存列表 和 可见列表
  func updateReuseableItemViews(){
    var itemsForRemove: [ZYPhotoView] = []
    // 离开可见区域
    for photoView in visibleItemViews {
      if photoView.frame.origin.x + photoView.frame.width < scrollView.contentOffset.x - scrollView.frame.width
        || photoView.frame.origin.x > scrollView.contentOffset.x + 2*scrollView.frame.width {
        photoView.removeFromSuperview()
        photoView.setItem(nil, determinate: false)
        itemsForRemove.append(photoView)
        self.reusableItemViews.append(photoView)
      }
    }
    // 从可见区域 移除
    for item in itemsForRemove {
      visibleItemViews = visibleItemViews.filter({ (photoView) -> Bool in
        if photoView.tag == item.tag {
          return false
        }else{
          return true
        }
      })
    }
  }
  
  /// 获取某页的 ZYPhotoView 如果没有 就从缓存池取
  ///
  /// - Parameter page: 页码
  /// - Returns: ZYPhotoView
  func photoViewForPage(_ page:Int) -> ZYPhotoView?{
    for photoView in visibleItemViews {
      if photoView.tag == page {
        return photoView
      }
    }
    return nil
  }
  
  /// 取一个复用的ZYPhotoView
  /// 如果没有就创建一个
  /// - Returns: ZYPhotoView
  func dequeueReusableItemView()->ZYPhotoView?{
    var photoView = reusableItemViews.last
    if photoView == nil {
      photoView = ZYPhotoView(frame: scrollView.bounds, imageManager: _imageManager)
    }else{
      reusableItemViews.removeLast()
    }
    photoView?.tag = -1
    return photoView
  }
  
  /// 页码改变
  func configItemViews(){
    let page = Int(scrollView.contentOffset.x/scrollView.frame.width + 0.5)
    for i in page-1...page+1{
      if i<0 || i>=photoItems.count{
        continue
      }
      var photoView = self.photoViewForPage(i)
      if photoView == nil {
        photoView = self.dequeueReusableItemView()
        var rect = scrollView.bounds
        rect.origin.x = CGFloat(i)*scrollView.bounds.width
        photoView?.frame = rect
        photoView?.tag = i
        scrollView.addSubview(photoView!)
        visibleItemViews.append(photoView!)
      }
      guard  let sphotoView = photoView else {
        return
      }
      if sphotoView.item == nil && _presented {
        let item = photoItems.zy_safeIndex(i)
        sphotoView.setItem(item, determinate: true)
      }
    }
    
    if page != currentPage && _presented && page>=0 && page<photoItems.count {
      let item = photoItems[page]
      self.currentPage = page
      self.configLabelWithPage(page)
      delegate?.zy_photoBrowser(self, didSelect: item, at: page)
    }
  }
  
}


// MARK: - UIViewControllerTransitioningDelegate,CAAnimationDelegate
extension ZYPhotoBrowser: UIViewControllerTransitioningDelegate,CAAnimationDelegate {
}

// MARK: - UIScrollViewDelegate
extension ZYPhotoBrowser: UIScrollViewDelegate {
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateReuseableItemViews()
    configItemViews()
  }
  
}


// MARK: - 手势相关
extension ZYPhotoBrowser {
  
  /// 初始化手势
  func setupGestureRecognize(){
    // 双击
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
    doubleTap.numberOfTapsRequired = 2
    self.view.addGestureRecognizer(doubleTap)
    
    // 单击
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(_:)))
    singleTap.numberOfTapsRequired = 1
    singleTap.require(toFail: doubleTap)
    self.view.addGestureRecognizer(singleTap)
    
    // 长按
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
    self.view.addGestureRecognizer(longPress)
    
    // 滑动
    let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    self.view.addGestureRecognizer(pan)
  }
  
  func didSingleTap(_ gesture:UITapGestureRecognizer){
    self.showDismissalAnimation()
  }
  
  func didDoubleTap(_ gesture:UITapGestureRecognizer){
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    let item = photoItems[currentPage]
    if !item.finished {
      // 未加载完成
      return
    }
    
    if photoView.zoomScale > 1 {
      photoView.setZoomScale(1, animated: true)
    }else{
      let location = gesture.location(in: self.view)
      let maxZoomScale = photoView.maximumZoomScale
      let width = self.view.bounds.size.width / maxZoomScale
      let height = self.view.bounds.height / maxZoomScale
      photoView.zoom(to: CGRect(x: location.x - width/2, y: location.y - height/2, width: width, height: height), animated: true)
    }
  }
  
  func didLongPress(_ gesture:UILongPressGestureRecognizer){
    
  }
  
  
  /// 滑动
  ///
  /// - Parameter gesture: gesture
  func didPan(_ gesture:UIPanGestureRecognizer){
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    if photoView.zoomScale > 1.1 {
      return
    }
    self.performScaleWithPan(gesture)
  }
  
  func performScaleWithPan(_ pan:UIPanGestureRecognizer) {
//    locationInView:获取到的是手指点击屏幕实时的坐标点；
//    translationInView：获取到的是手指移动后，在相对坐标中的偏移量
//    velocityInView：在指定坐标系统中pan gesture拖动的速度
    let point = pan.translation(in: self.view)
    let location = pan.location(in: self.view)
    let velocity = pan.velocity(in: self.view)
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    
    switch pan.state {
    case .began:
      _startLocation = location
      handlePanBegin()
    case .changed:
      var percent = 1 - fabs(point.y) / self.view.frame.height
      percent = max(percent, 0)
      let s = max(percent, 0.5)
      photoView.imageView.transform = CGAffineTransform.identity
                                        .translatedBy(x: point.x/s, y: point.y/s)
                                        .scaledBy(x: s, y: s)
      self.view.backgroundColor = UIColor(white: 0, alpha: percent)
    case .ended,.cancelled:
      if fabs(point.y) > 100 || fabs(velocity.y) > 500 {
        self.showDismissalAnimation()
      }else{
        self.showCancellationAnimation()
      }
    default:
      break
    }
    
  }
  
  /// 开始滑动
  func handlePanBegin(){
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    let item = self.photoItems[currentPage]
    UIApplication.shared.isStatusBarHidden = false
    photoView.progressLayer.isHidden = true
    item.sourceView?.alpha = 0
  }
  
  
  /// 取消dissmiss
  func showCancellationAnimation(){
    guard let item = self.photoItems.zy_safeIndex(currentPage) else {return }
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    item.sourceView?.alpha = 1
    if !item.finished {
      photoView.progressLayer.isHidden = false
    }
    UIView.animate(withDuration: ZYConstant.springAnimationDuration , animations: { 
      photoView.imageView.transform = CGAffineTransform.identity
      self.view.backgroundColor = UIColor.black
    }) { (b) in
      UIApplication.shared.setStatusBarHidden(true, with: .fade)
      photoView.setItem(item, determinate: true)
    }
  }
  
  /// 消失执行动画
  func showDismissalAnimation(){
    guard let item = self.photoItems.zy_safeIndex(currentPage) else {return }
    guard let photoView = self.photoViewForPage(currentPage) else { return }
    UIApplication.shared.isStatusBarHidden = false
    if item.sourceView == nil {
      // 在不可见范围
      UIView.animate(withDuration: 0.3, animations: { 
        self.view.alpha = 0
      }, completion: { (b) in
        self.dismissAnimated(false)
      })
      return
    }
    // 可见范围计算rect
    photoView.progressLayer.isHidden = true
    item.sourceView?.alpha = 0
    var sourceRect = CGRect.zero
    sourceRect = item.sourceView?.superview?.convert(item.sourceView!.frame , to: photoView) ?? CGRect.zero
    UIView.animate(withDuration: ZYConstant.springAnimationDuration , delay: 0, animations: {
      photoView.imageView.frame = sourceRect
      self.view.backgroundColor = UIColor.clear
    }) { (b) in
      self.dismissAnimated(false)
    }
  }
  func dismissAnimated(_ animated:Bool){
    let item = photoItems[currentPage]
    if animated {
      UIView.animate(withDuration: 0.3, animations: { 
        item.sourceView?.alpha = 1
      })
    }else{
      item.sourceView?.alpha = 1
    }
    self.dismiss(animated: false, completion: nil)
  }
  
}

























