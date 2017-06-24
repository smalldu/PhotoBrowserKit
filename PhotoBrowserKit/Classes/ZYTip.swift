//
//  ZYTip.swift
//  Pods
//
//  Created by duzhe on 2017/6/24.
//
//

import Foundation

class ZYTip: NSObject {
  
  static let shared:ZYTip = ZYTip()
  
  fileprivate var backView:UIView!
  fileprivate var tipImageView:UIImageView!
  fileprivate var titleLabel:UILabel!
  fileprivate var goPhotoBtn:UIButton!
  
  private override init() {
  }
  
  func showWith(title:String){
    backView = UIView()
    UIApplication.shared.keyWindow?.addSubview(backView)
    backView.frame = CGRect(x: 10 , y: 30, width: ZYConstant.sw - 20   , height: 45)
    backView.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
    backView.layer.cornerRadius = 12
    backView.layer.masksToBounds = true
    
    titleLabel = UILabel()
    backView.addSubview(titleLabel)
    titleLabel.frame = CGRect(x: 0 , y: 0 , width: ZYConstant.sw - 20 , height: 45)
    titleLabel.textColor = UIColor.black
    titleLabel.font = UIFont.systemFont(ofSize: 13)
    titleLabel.text = title
    titleLabel.textAlignment = .center
    
    backView.transform = CGAffineTransform(translationX: 0 , y: -85 )
    UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0 , initialSpringVelocity: 0 , options: UIViewAnimationOptions.curveEaseInOut , animations: {
      self.backView.transform = CGAffineTransform.identity
    }, completion: nil)
    
    ZYConstant.delay( 1 ) {
      UIView.animate(withDuration: 0.3, animations: {
        self.backView?.alpha = 0
      }) { b in
        self.backView?.removeFromSuperview()
        self.backView = nil
      }
    }
  }
  
  func foPhoto(){
    if let url = URL(string: "photos-redirect://") {
      if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
