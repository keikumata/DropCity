//
//  DropCircle.swift
//  Drop
//
//  Created by Hun Ro on 10/11/15.
//  Copyright (c) 2015 Hun Ro. All rights reserved.
//

import UIKit

class DropCircle: UIView {
  
  // customizable
  var averageDecibel: Float = 0
  var factor: Float = 1.6
  var animationDuration: CFTimeInterval = 0.1
  
  // initial position
  var initialX = CGFloat()
  var initialY = CGFloat()
  
  // gesture handlers
  var onPan:(sender: UIPanGestureRecognizer)->Void = { arg in }
  var onPanRelease:()->() = { }
  var onTouchDown: (sender: UIPanGestureRecognizer)->Void = { arg in }
  var onTouchUp: ()->() = {}
  
  // components
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
  func updateDecibel(radius: Float) {
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
      
      self.onPan(sender: sender)
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
      
      self.onPanRelease()
    default:
      break
    }
  }
  
  func tap (sender: UIButton) {
    circleLayer.opacity = 1.0
    self.onTouchDown(sender: panGesture)
  }
  
  func release (sender: UIButton) {
    circleLayer.opacity = 0.6
    self.onTouchUp()
  }
  
  // drawing and animation
  func drawCircle(frame: CGRect) {
    circleLayer.path = circlePathSmall.CGPath
    circleLayer.fillColor = UIColor.whiteColor().CGColor
    circleLayer.opacity = 0.6
    self.layer.addSublayer(circleLayer)
  }
  
  func animateCircle(radius: Float) {
    let update = CGFloat(radius*factor)
    UIView.animateWithDuration(self.animationDuration, animations: {
      self.transform = CGAffineTransformMakeScale(update, update)
      }, completion: {
        (value: Bool) -> Void in
        UIView.animateWithDuration(self.animationDuration, animations: {
          self.transform = CGAffineTransformMakeScale(1,1)
        })
    })
  }
  
}
