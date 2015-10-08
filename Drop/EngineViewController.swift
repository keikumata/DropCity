//
//  EngineViewController.swift
//  Drop
//
//  Created by Hun Ro on 10/7/15.
//  Copyright (c) 2015 Drop. All rights reserved.
//

import UIKit
import AVFoundation

class EngineViewController: UIViewController {
  
  var playing: Bool = false
  
  var sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("trap", ofType: "mp3")!)
  var audioEngine = AVAudioEngine()
  var player1 = AVAudioPlayerNode()
  var player2 = AVAudioPlayerNode()
  var buffer = AVAudioPCMBuffer()
  var file = AVAudioFile()
  var total: Double = 0;
  var pitch = AVAudioUnitTimePitch()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    player1.volume = 1
    player2.volume = 1
    
    file = AVAudioFile(forReading: sound, error: nil)
    buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
    var shortBuffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length/30))
    file.readIntoBuffer(buffer, error: nil)
    
    var mainMixer = audioEngine.mainMixerNode
    var reverb = AVAudioUnitReverb()
    reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
    reverb.wetDryMix = 50
    
    
    pitch.pitch = 10
    
    audioEngine.attachNode(player1)
    audioEngine.attachNode(player2)
    audioEngine.attachNode(reverb)
    audioEngine.attachNode(pitch)
    
    audioEngine.connect(player1, to: mainMixer, format: buffer.format)
    //    audioEngine.connect(pitch, to: mainMixer, format: buffer.format)
    audioEngine.connect(player2, to: pitch, format: buffer.format)
    audioEngine.connect(pitch, to: mainMixer, format: buffer.format)
    
    player1.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
    
    audioEngine.prepare()
    audioEngine.startAndReturnError(nil)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func playButtonPressed(sender: UIButton) {
    if (playing) {
      player1.pause()
      playing = false
    } else {
      player1.play()
      playing = true
    }
  }
  
  var frametime = AVAudioFramePosition()
  var framestoplay = AVAudioFrameCount()
  
  @IBAction func timeButtonPressed(sender: UIButton) {
    if (playing) {
      var nodetime: AVAudioTime  = player1.lastRenderTime
      var playerTime: AVAudioTime = player1.playerTimeForNodeTime(nodetime)
      var sampleRate = Double(playerTime.sampleRate)
      var sampleTime = Double(playerTime.sampleTime)
      frametime = AVAudioFramePosition(sampleTime)
      print("frametime: \(frametime)\n")
      //      var length = Float(file.length) - Float(frametime);
      //      print("length: \(length)\n")
      framestoplay = AVAudioFrameCount(2*sampleRate)
      print("framestoplay: \(framestoplay)\n")
      incPitch()
      NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "incPitch", userInfo: nil, repeats: true)
    }
  }
  
  func incPitch() {
    
    
    //    player.stop()
    //    player2.pause()
    pitch.pitch += 40
    print("before: \(pitch.rate)\n")
    pitch.rate += 0.1
    print("after: \(pitch.rate)\n")
    player2.scheduleSegment(file, startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: nil)
    player2.play()
  }
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
