# PhotoBrowserKit

[![CI Status](http://img.shields.io/travis/smalldu/PhotoBrowserKit.svg?style=flat)](https://travis-ci.org/smalldu/PhotoBrowserKit)
[![Version](https://img.shields.io/cocoapods/v/PhotoBrowserKit.svg?style=flat)](http://cocoapods.org/pods/PhotoBrowserKit)
[![License](https://img.shields.io/cocoapods/l/PhotoBrowserKit.svg?style=flat)](http://cocoapods.org/pods/PhotoBrowserKit)
[![Platform](https://img.shields.io/cocoapods/p/PhotoBrowserKit.svg?style=flat)](http://cocoapods.org/pods/PhotoBrowserKit)

## Introduction
This project is highly imitate from [KSPhotoBrowser](https://github.com/skx926/KSPhotoBrowser) - an Objective-C project
， I just rewrite some feature use `Swift`

It's smart and awesome ! 

![demo](https://github.com/smalldu/PhotoBrowserKit/blob/master/picture/demo.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This library requires iOS 8.0+ and Xcode 8.0+

## Installation

PhotoBrowserKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PhotoBrowserKit"
```

## Usage

```swift
var items: [ZYPhotoItem] = []
for i in 0..<urls.count {
  let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? PhotoCell
  // big url
  let bigUrl = urls[i].replacingOccurrences(of: "bmiddle", with: "large")
  let item = ZYPhotoItem()
  // imageView
  item.sourceView = cell?.imageView
  item.imageURL = URL(string: bigUrl)
  item.thunbImage = cell?.imageView.image
  items.append(item)
}
let browser = ZYPhotoBrowser(photoItems: items, selectedIndex: indexPath.row)
browser.showFromViewController(self)
```

## Author

smalldu, 363958265@qq.com

## License

PhotoBrowserKit is available under the MIT license. See the LICENSE file for more info.
