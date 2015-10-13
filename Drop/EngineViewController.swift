//
//  EngineViewController.swift
//  Drop
//
//  Created by Kei Yoshikoshi and Hun Ro on 10/7/15.
//  Copyright (c) 2015 Drop. All rights reserved.
//

import UIKit
import AVFoundation

class EngineViewController: UIViewController {
    
    var playing: Bool = false
    var start: Bool = true
    
    var sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jb", ofType: "mp3")!)
    var trap = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("grimedropsecond", ofType: "mp3")!)
    var clap = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("clap", ofType: "mp3")!)
    var reverb = AVAudioUnitReverb()
    var audioEngine = AVAudioEngine()
    var player1 = AVAudioPlayerNode()
    var looper = AVAudioPlayerNode()
    var trapPlayer = AVAudioPlayerNode()
    var clapPlayer = AVAudioPlayerNode()
    
    var buffer = AVAudioPCMBuffer()
    var file = AVAudioFile()
    
    var trapbuffer = AVAudioPCMBuffer()
    var trapfile = AVAudioFile()
    
    var clapbuffer = AVAudioPCMBuffer()
    var clapfile = AVAudioFile()

    var total: Double = 0;
    var pitch = AVAudioUnitTimePitch()
    var clappitch = AVAudioUnitTimePitch()

    var firstHeight:Float?
    var firstWidth:Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player1.volume = 1
        looper.volume = 1
        trapPlayer.volume = 1
        clapPlayer.volume = 0.5
        clappitch.rate = 0.5
        
        // set up original track
        do {
            file = try AVAudioFile(forReading: sound)
        } catch  {}
        buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        do {
             try file.readIntoBuffer(buffer)
        } catch  {}
       
        
        // set up trap track
        do {
            trapfile = try AVAudioFile(forReading: trap)
        } catch {}
        trapbuffer = AVAudioPCMBuffer(PCMFormat: trapfile.processingFormat, frameCapacity: AVAudioFrameCount(trapfile.length))
        do {
            try trapfile.readIntoBuffer(trapbuffer)
        } catch {}
        
        // set up clap track
        do {
            clapfile = try AVAudioFile(forReading: clap)
        } catch  {}
        clapbuffer = AVAudioPCMBuffer(PCMFormat: clapfile.processingFormat, frameCapacity: AVAudioFrameCount(clapfile.length))
        do {
            try  clapfile.readIntoBuffer(clapbuffer)
        } catch  {}
       
        
        //set up audio engine
        let mainMixer = audioEngine.mainMixerNode
        
        pitch.pitch = 10
        clappitch.pitch = 10
        audioEngine.attachNode(player1)
        audioEngine.attachNode(looper)
        audioEngine.attachNode(trapPlayer)
        audioEngine.attachNode(reverb)
        audioEngine.attachNode(pitch)
        audioEngine.attachNode(clappitch)
        audioEngine.attachNode(clapPlayer)
        
        audioEngine.connect(player1, to: mainMixer, format: buffer.format)
        audioEngine.connect(looper, to: pitch, format: buffer.format)
        audioEngine.connect(pitch, to: reverb, format:buffer.format)
        audioEngine.connect(reverb, to: mainMixer, format: buffer.format)
        audioEngine.connect(trapPlayer, to:mainMixer, format:trapbuffer.format)
        audioEngine.connect(clapPlayer, to: clappitch, format: clapbuffer.format)
        audioEngine.connect(clappitch, to: mainMixer, format: clapbuffer.format)
        
        player1.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
        trapPlayer.scheduleBuffer(trapbuffer, atTime: nil, options: .Loops, completionHandler: nil)
        clapPlayer.scheduleBuffer(clapbuffer, atTime:nil, options: .Loops, completionHandler: nil)
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {}
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
    var framestoplaydouble = AVAudioFrameCount()
    var framestoplaytriple = AVAudioFrameCount()
    var framestoplayquadruple = AVAudioFrameCount()
    var clapframetime = AVAudioFramePosition()
    var clapframestoplay = AVAudioFrameCount()
    
    // this function sets up the looping of the track and number of frames it runs
    func startIncreasing(){
        if (playing) {
            let nodetime: AVAudioTime  = player1.lastRenderTime!
            let playerTime: AVAudioTime = player1.playerTimeForNodeTime(nodetime)!
            let sampleRate = Double(playerTime.sampleRate)
            let sampleTime = Double(playerTime.sampleTime)
            frametime = AVAudioFramePosition(sampleTime)
            print("frametime: \(frametime)\n")
            framestoplay = AVAudioFrameCount(2*sampleRate)
            framestoplaydouble = AVAudioFrameCount(0.8*sampleRate)
            framestoplaytriple = AVAudioFrameCount(0.2*sampleRate)
            framestoplayquadruple = AVAudioFrameCount(0.1*sampleRate)
            print("framestoplay: \(framestoplay)\n")
            clapPlayer.play()
            looper.scheduleSegment(file, startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
                // do some audio work
               self.repeatStart()
            })
            looper.play()
        }
    }
    func repeatStart() {
        if (start){
            looper.scheduleSegment(file, startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
                // do some audio work
                self.repeatStart()
            })
            looper.play()
        }
    }
    var originalRate:Bool = true
    var doubleRate:Bool = true
    var tripleRate:Bool = true
    var frames:AVAudioFrameCount?
    var rate:Float = 1
    
    // this function increases the pitch and rate based on the coordinate locations
    func incPitchAndRate(pitch_change: Float, rate_change: Float) {
        pitch.pitch += pitch_change/200
        print("before: \(pitch.rate)\n")
        pitch.rate += rate_change/25000
        clappitch.rate += rate_change/20000
        print("after: \(pitch.rate)\n")
        
        if (pitch.rate <= 1.5 && originalRate) {
            frames = framestoplay
        }
        else if (pitch.rate > 1.5 && pitch.rate <= 2.5 && doubleRate) {
            print("double");
            doubleRate = false
            looper.stop()
            frames = framestoplaydouble
        }
        else if (pitch.rate>2.5 && tripleRate) {
            print("triple")
            tripleRate = false
            looper.stop()
            frames = framestoplaytriple
        }
        clapPlayer.play()
        looper.scheduleSegment(file, startingFrame: frametime, frameCount: frames!, atTime: nil,completionHandler: nil)
        looper.play()
    }
    
    // this function is called when the hold is released - runs the last loop and then calls trap
    func releasedHold() {
        pitch.pitch = 10
        pitch.rate = 1
        clapPlayer.stop()
        looper.stop()
        looper.scheduleSegment(file, startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
            print("it's done")
            self.timeTrap();
        })
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Plate)
        reverb.wetDryMix = 30
        looper.play()
    }
    
    // runs the trap player
    func timeTrap() {
        print("timer is running")
        let delay = 0.95*Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.trapPlayer.play()
        }
    }
    
    
  
    @IBAction func dropButtonPressed(sender: UIButton) {
        let firstPoint = panGesture.locationInView(self.view)
        firstWidth = Float(firstPoint.x)
        firstHeight = Float(firstPoint.y)
        startIncreasing()
        player1.pause()
        //add something you want to happen when the Label Panning has started
    }
    @IBAction func handlePanPress(panGesture: UIPanGestureRecognizer) {
        dropCircle.pan(panGesture)
        if panGesture.state == UIGestureRecognizerState.Ended {
            //add something you want to happen when the Label Panning has ended
            print("stopped")
            releasedHold()
        }
        if panGesture.state == UIGestureRecognizerState.Changed {
            start = false;
            let height = panGesture.locationInView(self.view).y;
            let width = panGesture.locationInView(self.view).x;
            let rate_change = firstHeight! - Float(height)
            let pitch_change = Float(width) - firstWidth!
            incPitchAndRate(pitch_change, rate_change: rate_change)
            print(rate_change)
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet var dropCircle: DropCircle!
    // this function handles the pan gesture
    @IBOutlet weak var dropButton: UIButton!
}
