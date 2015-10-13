//
//  DropCircle.swift
//  Drop
//
//  Created by Hun Ro on 10/12/15.
//  Copyright (c) 2015 Drop. All rights reserved.
//

import UIKit

class DropCircle: UIView {
<<<<<<< HEAD
    
    var initialX = CGFloat()
    var initialY = CGFloat()
    
    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var circleLayer = CAShapeLayer()
    var circlePathSmall: UIBezierPath = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup(frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup(frame)
    }
    
    func setup(frame: CGRect) {
        self.initialX = frame.origin.x
        self.initialY = frame.origin.y
        circlePathSmall = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.backgroundColor = UIColor.clearColor()
        
        // pan
//        self.addGestureRecognizer(panGesture)
//        panGesture.addTarget(self, action: "pan:")
        self.userInteractionEnabled = true
        
        self.drawCircle(frame)
    }
    
    func updateDecibel(radius: CGFloat) {
        self.animateCircle(radius)
    }
    
    func pan(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Ended) {
            var circleContainerFrame: CGRect = frame
            circleContainerFrame.origin.x = self.initialX
            circleContainerFrame.origin.y = self.initialY
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            
            frame = circleContainerFrame
            UIView.commitAnimations()
            circleLayer.opacity = 0.6
        } else {
            // get new coordinates of pangesture in relation to view (self)
            let translation: CGPoint = sender.translationInView(self)
            
            // add translation to view center to reset the center of pangesture (movement)
            //      sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
            var newFrame = self.frame
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            self.frame = newFrame
            // reset the pangesture to prevent translation from compounding and flying off
            sender.setTranslation(CGPointMake(0,0), inView: self)
            circleLayer.opacity = 1.0
        }
    }
    
    
    
    // draw initial circle
    func drawCircle(frame: CGRect) {
        //    circleLayer.frame = frame
        circleLayer.path = circlePathSmall.CGPath
        circleLayer.fillColor = UIColor.whiteColor().CGColor
        circleLayer.opacity = 0.6
        self.layer.addSublayer(circleLayer)
    }
    
    // animate pulse
    func animateCircle(radius: CGFloat) {
        var circlePathLarge: UIBezierPath {
            return UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: (frame.width*radius), height: (frame.height*radius)))
        }
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = circlePathSmall.CGPath
        expandAnimation.toValue = circlePathLarge.CGPath
        expandAnimation.beginTime = 0.0
        expandAnimation.duration = 0.1
        
        let contractAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        contractAnimation.fromValue = circlePathLarge.CGPath
        contractAnimation.toValue = circlePathSmall.CGPath
        contractAnimation.beginTime = expandAnimation.beginTime + expandAnimation.duration
        contractAnimation.duration = 0.1
        
        let animationGroup: CAAnimationGroup = CAAnimationGroup()
        animationGroup.animations = [expandAnimation, contractAnimation]
        animationGroup.duration = contractAnimation.beginTime + contractAnimation.duration
        animationGroup.repeatCount = 1
        circleLayer.addAnimation(animationGroup, forKey: nil)
    }
    
}
=======

  var initialX = CGFloat()
  var initialY = CGFloat()
  
  var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
  
  var circleLayer = CAShapeLayer()
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
    
    // pan
    self.addGestureRecognizer(panGesture)
    panGesture.addTarget(self, action: "pan:")
    self.userInteractionEnabled = true
    
    self.drawCircle(frame)
  }
  
  func updateDecibel(radius: CGFloat) {
    self.animateCircle(radius)
  }
  
  func pan(sender: UIPanGestureRecognizer) {
    if (sender.state == UIGestureRecognizerState.Ended) {
      var circleContainerFrame: CGRect = frame
      circleContainerFrame.origin.x = self.initialX
      circleContainerFrame.origin.y = self.initialY
      
      UIView.beginAnimations(nil, context: nil)
      UIView.setAnimationDuration(0.5)
      UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
      
      frame = circleContainerFrame
      UIView.commitAnimations()
      circleLayer.opacity = 0.6
    } else {
      // get new coordinates of pangesture in relation to view (self)
      var translation: CGPoint = sender.translationInView(self)
      
      // add translation to view center to reset the center of pangesture (movement)
      //      sender.view!.center = CGPointMake(sender.view!.center.x + translation.x, sender.view!.center.y + translation.y)
      var newFrame = self.frame
      newFrame.origin.x += translation.x
      newFrame.origin.y += translation.y
      self.frame = newFrame
      // reset the pangesture to prevent translation from compounding and flying off
      sender.setTranslation(CGPointMake(0,0), inView: self)
      circleLayer.opacity = 1.0
    }
  }

  
  
  // draw initial circle
  func drawCircle(frame: CGRect) {
    //    circleLayer.frame = frame
    circleLayer.path = circlePathSmall.CGPath
    circleLayer.fillColor = UIColor.whiteColor().CGColor
    circleLayer.opacity = 0.6
    self.layer.addSublayer(circleLayer)
  }
  
  // animate pulse
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
>>>>>>> f1d9bb28619dc09d5a10ec26bf275a4d5c725788
