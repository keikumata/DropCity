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
    var trap = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("forbesdrop", ofType: "mp3")!)
    var clap = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("clap", ofType: "mp3")!)
    var reverb = AVAudioUnitReverb()
    var audioEngine = AVAudioEngine()
    var mainPlayer = AVAudioPlayerNode()
    var looper = AVAudioPlayerNode()
    var trapPlayer = AVAudioPlayerNode()
    var clapPlayer = AVAudioPlayerNode()
    var currentPlayer = AVAudioPlayerNode()
    
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
    var startTimer: NSDate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainPlayer.volume = 1
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
        pitch.rate = 1;
        clappitch.pitch = 10
        audioEngine.attachNode(mainPlayer)
        audioEngine.attachNode(looper)
        audioEngine.attachNode(trapPlayer)
        audioEngine.attachNode(reverb)
        audioEngine.attachNode(pitch)
        audioEngine.attachNode(clappitch)
        audioEngine.attachNode(clapPlayer)
        
        audioEngine.connect(mainPlayer, to: mainMixer, format: buffer.format)
        audioEngine.connect(looper, to: pitch, format: buffer.format)
        audioEngine.connect(pitch, to: reverb, format:buffer.format)
        audioEngine.connect(reverb, to: mainMixer, format: buffer.format)
        audioEngine.connect(trapPlayer, to:mainMixer, format:trapbuffer.format)
        audioEngine.connect(clapPlayer, to: clappitch, format: clapbuffer.format)
        audioEngine.connect(clappitch, to: mainMixer, format: clapbuffer.format)
        
        mainPlayer.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)
        trapPlayer.scheduleBuffer(trapbuffer, atTime: nil, options: .Loops, completionHandler: nil)
        clapPlayer.scheduleBuffer(clapbuffer, atTime:nil, options: .Loops, completionHandler: nil)
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {}
        
        dropCircle.onPan = self.onPanChange
        dropCircle.onPanRelease = self.releasedHold
        dropCircle.onTouchDown = self.onTapPressed
        dropCircle.onTouchUp = self.onTapReleased
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if (playing) {
            mainPlayer.pause()
            playing = false
        } else {
            mainPlayer.play()
            playing = true
            currentPlayer = mainPlayer;
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
    func startIncreasing(looptime: NSTimeInterval){
        if (playing) {
            let nodetime: AVAudioTime  = currentPlayer.lastRenderTime!
            let playerTime: AVAudioTime = currentPlayer.playerTimeForNodeTime(nodetime)!
            let sampleRate = Double(playerTime.sampleRate)
            let sampleTime = Double(playerTime.sampleTime) - looptime*sampleRate
            frametime = AVAudioFramePosition(sampleTime)
            print("frametime: \(frametime)\n")
            framestoplay = AVAudioFrameCount(looptime*sampleRate)
            framestoplaydouble = AVAudioFrameCount(0.8*sampleRate)
            framestoplaytriple = AVAudioFrameCount(0.3*sampleRate)
            print("framestoplay: \(framestoplay)\n")
            clapPlayer.play()
            looper.scheduleSegment(chooseFile(), startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
               self.repeatStart()
            })
            looper.play()
        }
    }
    func repeatStart() {
        if (start){
            looper.scheduleSegment(chooseFile(), startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
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
        looper.scheduleSegment(chooseFile(), startingFrame: frametime, frameCount: frames!, atTime: nil,completionHandler: nil)
        looper.play()
    }
    
    // this function is called when the hold is released - runs the last loop and then calls trap
    func releasedHold() {
        pitch.pitch = 10
        pitch.rate = 1
        clapPlayer.stop()
        looper.stop()
        looper.scheduleSegment(chooseFile(), startingFrame: frametime, frameCount: framestoplay, atTime: nil,completionHandler: { () -> Void in
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
        let delay = 1.00*Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.trapPlayer.play()
            self.currentPlayer = self.trapPlayer
        }
    }
    // MAKE IT SO THAT YOU CAN'T DRAG WITHOUT THE FIRST HOLD
    
    func onPanChange(panGesture: UIPanGestureRecognizer) {
        start = false;
        let height = panGesture.locationInView(self.view).y;
        let width = panGesture.locationInView(self.view).x;
        let rate_change = firstHeight! - Float(height)
        let pitch_change = Float(width) - firstWidth!
        incPitchAndRate(pitch_change, rate_change: rate_change)
        print(rate_change)
    }
    func onTapPressed (panGesture: UIPanGestureRecognizer) {
        let firstPoint = panGesture.locationInView(self.view)
        firstWidth = Float(firstPoint.x)
        firstHeight = Float(firstPoint.y)
        startTimer = NSDate()
        
        reverb.reset() // clearly not working
        print("THIS IS REVERB \(reverb.wetDryMix)")
    }
    func onTapReleased() {
        let timeElapsed = abs(startTimer!.timeIntervalSinceNow)
        startIncreasing(timeElapsed)
        currentPlayer.pause()
        start = true
    }
    
    func chooseFile() -> (AVAudioFile) {
        if (currentPlayer == mainPlayer) {
            return file;
        }
        else if (currentPlayer == trapPlayer) {
            return trapfile;
        }
        return file;
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet var dropCircle: DropCircle!
}
