//
//  ZYMenuView.swift
//  Pods
//
//  Created by duzhe on 2017/9/15.
//
//

import UIKit


protocol ZYMenuViewDelegate: class {
  func zy_menuViewDidClick(at index: Int)
}

class ZYMenuView: UIView , ZYMenuViewLabelDelegate{
  
  let _sw: CGFloat = UIScreen.main.bounds.width
  var menuItems: [String] = []
  
  weak var delegate: ZYMenuViewDelegate?
  lazy var labelItems: [ZYMenuViewLabel] = {
    var items: [ZYMenuViewLabel] = []
    for item in self.menuItems {
      let label = ZYMenuViewLabel()
      label.text = item
      label.textAlignment = .center
      label.font = UIFont.systemFont(ofSize: 15)
      items.append(label)
    }
    return items
  }()
  var itemWidth: CGFloat = 40
  var itemHeight: CGFloat = 37
  var lineWidth: CGFloat = 12
  
  
  let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 1
    view.layer.masksToBounds = true
    return view
  }()
  
  
  private(set) var selectedIndex: Int = 0
  
  init( menuItems: [String] ) {
    self.menuItems = menuItems
    super.init(frame:.zero)
    prepareView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    prepareView()
  }
  
  func prepareView(){
    backgroundColor = UIColor.white
    itemWidth = _sw / CGFloat(menuItems.count)
    for (i,item) in labelItems.enumerated() {
      addSubview(item)
      item.tag = 100 + i
      item.frame = CGRect(x: CGFloat(i)*itemWidth , y: 0 , width: itemWidth , height: itemHeight)
      if i == 0 {
        item.selected()
      }else{
        item.deSelected()
      }
      item.registerTap()
      item.delegate = self
    }
    
    addSubview(lineView)
    lineView.frame = CGRect(x:(itemWidth - lineWidth)/2 , y: itemHeight , width: lineWidth , height: 3)
  }
  
  func zy_menuViewLabelDidClick(_ label: ZYMenuViewLabel) {
    let index = max(label.tag - 100, 0)
    if index == self.selectedIndex { // 未改变
      return
    }
    self.selectedIndex = index
    for item in labelItems {
      item.deSelected()
    }
    label.selected()
    scrollLineView()
    delegate?.zy_menuViewDidClick(at: index)
  }
  
  func scrollTo(_ index: Int) {
    self.selectedIndex = index
    for item in labelItems {
      item.deSelected()
    }
    labelItems[index].selected()
    scrollLineView()
  }
  
  func scrollLineView(){
    UIView.animate(withDuration: 0.3 , animations: { [weak self] in
      guard let `self` = self else{ return }
      self.lineView.frame.origin.x = (CGFloat(self.selectedIndex)*self.itemWidth) + (self.itemWidth - self.lineWidth)/2
      }, completion: nil)
  }
  
  func reloadTitles(){
    DispatchQueue.main.async {
      for (index,item) in self.menuItems.enumerated() {
        self.labelItems[index].text = item
      }
    }
  }
}

protocol ZYMenuViewLabelDelegate: class {
  func zy_menuViewLabelDidClick( _ label: ZYMenuViewLabel )
}
class ZYMenuViewLabel: UILabel {
  
  weak var delegate: ZYMenuViewLabelDelegate?
  private(set) var isSelected: Bool = false
  func selected(){
    isSelected = true
    textColor = UIColor.white
  }
  func deSelected(){
    isSelected = false
    textColor = UIColor.lightGray
  }
  
  func registerTap(){
    isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(click))
    addGestureRecognizer(tap)
  }
  
  @objc func click(){
    print("clicked")
    delegate?.zy_menuViewLabelDidClick(self)
  }
}
