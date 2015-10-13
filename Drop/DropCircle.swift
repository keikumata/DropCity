//
//  DropCircle.swift
//  Drop
//
//  Created by Hun Ro on 10/11/15.
//  Copyright (c) 2015 Hun Ro. All rights reserved.
//

import UIKit

class DropCircle: UIView {
  
  // default settings for programmatic
  let defaultWidth: CGFloat = 20
  let defaultHeight: CGFloat = 20
  
  // customizable
  var averageDecibel: Float = 0.0
  var factor: Int = 1
  
  // initial position
  var initialX = CGFloat()
  var initialY = CGFloat()
  
  // handlers 
  var onPan: ()->() = {}
  var onRelease: ()->() = {}
  var onTap: ()->() = {}
  
  let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
  let buttonTap: UIButton = UIButton()
  
  let circleLayer = CAShapeLayer()
  var circlePathSmall: UIBezierPath = UIBezierPath()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup(frame)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setup(frame)
  }
  
  func setup(frame: CGRect) {
    self.initialX = frame.origin.x
    self.initialY = frame.origin.y
    
    circlePathSmall = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    self.backgroundColor = UIColor.clearColor()
    
    self.addGestureRecognizer(panGesture)
    panGesture.addTarget(self, action: "pan:")
    
    buttonTap.frame = CGRect(x:0, y:0, width: frame.width, height: frame.height)
    buttonTap.addTarget(self, action: "tap:", forControlEvents: UIControlEvents.TouchDown)
    buttonTap.addTarget(self, action: "release:", forControlEvents: UIControlEvents.TouchUpInside)
    self.addSubview(buttonTap)
    
    self.userInteractionEnabled = true
    self.drawCircle(frame)
  }
  
  // update called from controller
  func updateDecibel(radius: CGFloat) {
    self.animateCircle(radius)
  }
  
  // gesture handlers
  func pan(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Changed:
      var translation: CGPoint = sender.translationInView(self)
      var newFrame = self.frame
      newFrame.origin.x += translation.x
      newFrame.origin.y += translation.y
      self.frame = newFrame
      
      // reset the pangesture to prevent translation from compounding and flying off
      sender.setTranslation(CGPointMake(0,0), inView: self)
      circleLayer.opacity = 1.0
      
      self.onPan()
    case .Ended:
      var circleContainerFrame: CGRect = frame
      circleContainerFrame.origin.x = self.initialX
      circleContainerFrame.origin.y = self.initialY
      
      UIView.beginAnimations(nil, context: nil)
      UIView.setAnimationDuration(0.5)
      UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
      
      frame = circleContainerFrame
      UIView.commitAnimations()
      circleLayer.opacity = 0.6
      
      self.onRelease()
    default:
      break
    }
  }
  
  func tap (sender: UIButton) {
    circleLayer.opacity = 1.0
    self.onTap()
  }
  
  func release (sender: UIButton) {
    circleLayer.opacity = 0.6
  }
  
  // drawing and animation
  func drawCircle(frame: CGRect) {
    circleLayer.path = circlePathSmall.CGPath
    circleLayer.fillColor = UIColor.whiteColor().CGColor
    circleLayer.opacity = 0.6
    self.layer.addSublayer(circleLayer)
  }
  
  func animateCircle(radius: CGFloat) {
    var circlePathLarge: UIBezierPath {
      return UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: (frame.width*radius), height: (frame.height*radius)))
    }
    var expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
    expandAnimation.fromValue = circlePathSmall.CGPath
    expandAnimation.toValue = circlePathLarge.CGPath
    expandAnimation.beginTime = 0.0
    expandAnimation.duration = 0.1
    
    var contractAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
    contractAnimation.fromValue = circlePathLarge.CGPath
    contractAnimation.toValue = circlePathSmall.CGPath
    contractAnimation.beginTime = expandAnimation.beginTime + expandAnimation.duration
    contractAnimation.duration = 0.1
    
    var animationGroup: CAAnimationGroup = CAAnimationGroup()
    animationGroup.animations = [expandAnimation, contractAnimation]
    animationGroup.duration = contractAnimation.beginTime + contractAnimation.duration
    animationGroup.repeatCount = 1
    circleLayer.addAnimation(animationGroup, forKey: nil)
  }
  
}
