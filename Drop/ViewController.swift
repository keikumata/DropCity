//
//  ViewController.swift
//  Drop
//
//  Created by Kei Yoshikoshi on 10/5/15.
//  Copyright (c) 2015 Drop. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
    
    var screenHeight:CGFloat?
    var audioPlayer = AVAudioPlayer()
    var playerItem:AVPlayerItem?
    var avplayer:AVPlayer?
    var engine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    var auTimePitch = AVAudioUnitTimePitch()
    var pressedTime: NSTimeInterval?
//    var goBackTo: NSTimeInterval?
    var goBackTo:UInt64?
    var soundTimer: NSTimer?
    var rate:Float?
    var firstHeight:Float?
    var rate_change:Float?
    var error:NSError?
    var temp:Double?
    var reverbPlayers:[AVPlayer] = []
    let N:Int = 10
    var sampleRate: Double?
    
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet var LongPressView: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib;
        
        // determining screen dimensions
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        screenHeight = screenSize.height
        
        
        var sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dream", ofType: "mp3")!);
        playerItem = AVPlayerItem(URL: sound)
        playerItem!.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed
        avplayer=AVPlayer(playerItem: playerItem!)
        let playerLayer=AVPlayerLayer(player: avplayer!)
        playerLayer.frame=CGRectMake(0, 0, 300, 50)
        self.view.layer.addSublayer(playerLayer)
  

        
        
        // audioPlayer stuff
//        audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: &error)
//        audioPlayer.prepareToPlay()
//        audioPlayer.enableRate = true

        
        // audioEngine stuff
//        let audioFile = AVAudioFile(forReading: sound, error: &error)
//        sampleRate = audioFile.fileFormat.sampleRate
//        audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: &error)
//        audioPlayer.prepareToPlay()
//        audioPlayer.enableRate = true
//        engine = AVAudioEngine()
//        playerNode = AVAudioPlayerNode()
//        engine.attachNode(playerNode)
//        
//        var mixer = engine.mainMixerNode;
//        engine.attachNode(auTimePitch)
//        engine.connect(playerNode, to: auTimePitch, format: audioFile.processingFormat)
//        engine.connect(auTimePitch, to: engine.outputNode, format: audioFile.processingFormat)
//        
//        
//        playerNode.scheduleFile(audioFile, atTime:nil, completionHandler:nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            rate_change = 0 // initially it's 0
            player();
            var firstPoint = sender.locationInView(self.view)
            firstHeight = Float(firstPoint.y)
        case .Changed:
            var height = sender.locationInView(self.view).y;
            var difference = firstHeight! - Float(height)
            rate_change = difference / 500;
//            println("DIFFERENCE IS \(difference)")
//            println("RELATIVE DISTANCE IS \(difference/500)")
//            avplayer!.rate = avplayer!.rate + difference/500
            
            // now think about how to repeat without constant timer repeats
        case .Ended:
            stopper();
        default: break;
        }
    }
    
//    func returnTimeInSeconds() -> AVAudioTime {
//        var nodeTime = playerNode.lastRenderTime
////        var playerTime = playerNode.playerTimeForNodeTime(nodeTime)
//        var seconds = Double(nodeTime.sampleTime) / sampleRate!
//        return AVAudioTime(sampleTime: Int64(seconds), atRate: sampleRate!)
//    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
                avplayer!.seekToTime(CMTimeMake(50, 1))
                avplayer!.play()
        //        audioPlayer.currentTime = 20;
        //        audioPlayer.play()
        
//        if engine.running {
//            playerNode.playAtTime(AVAudioTime(hostTime:UInt64(50)))
////            playerNode.play()
//        } else {
//            if !engine.startAndReturnError(&error) {
//                println("error couldn't start engine")
//                if let e = error {
//                    println("error \(e.localizedDescription)")
//                }
//            } else {
//                playerNode.playAtTime(AVAudioTime(hostTime:UInt64(50)))
////                playerNode.play()
//            }
//        }
    }

    func soundTimerPlayed() {

        let t1 = Float(avplayer!.currentTime().value)
        let t2 = Float(avplayer!.currentTime().timescale)
        let currentSeconds = t1 / t2
        println("current time is \(currentSeconds)")
        println("going back to \(goBackTo!)")
        avplayer!.seekToTime(CMTimeMake(Int64(goBackTo!), 1))
        avplayer!.play()
        avplayer!.rate = avplayer!.rate+rate_change!
        println(avplayer!.rate)
        
//        playerNode.playAtTime(UInt64(goBackTo!))
        
        if (avplayer!.rate<=1.5) {
            soundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(2/avplayer!.rate), target: self, selector: Selector("soundTimerPlayed"), userInfo: nil, repeats: false)
        }
        else if (avplayer!.rate>1.5 && avplayer!.rate<=1.7){
            soundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(2/(1.5*avplayer!.rate)), target: self, selector: Selector("soundTimerPlayed"), userInfo: nil, repeats: false)
        }
        else if (avplayer!.rate>1.7 && avplayer!.rate<=1.9){
            soundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(2/(2*avplayer!.rate)), target: self, selector: Selector("soundTimerPlayed"), userInfo: nil, repeats: false)
        }
        else {
            soundTimer = NSTimer.scheduledTimerWithTimeInterval(Double(2/(3*avplayer!.rate)), target: self, selector: Selector("soundTimerPlayed"), userInfo: nil, repeats: false)
        }
    }
    func player() {
        let t1 = Float(avplayer!.currentTime().value)
        let t2 = Float(avplayer!.currentTime().timescale)
        let currentSeconds = t1 / t2
        
        goBackTo = UInt64(currentSeconds) - 2
        println(goBackTo!)
//        rate = playerNode.rate
        
        rate = avplayer!.rate;
        
//        pressedTime = audioPlayer.currentTime
//        goBackTo = pressedTime! - 2.0
        soundTimerPlayed()
        
//
//        auTimePitch.pitch = 2 // In cents. The default value is 1.0. The range of values is -2400 to 2400
//        auTimePitch.rate = 5 //The default value is 1.0. The range of supported values is 1/32 to 32.0.
    }
    func stopper() {
        soundTimer!.invalidate();
        avplayer!.rate = 1;
        avplayer!.pause();
        soundTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("playDrop"), userInfo: nil, repeats: false)
    }
    func playDrop() {
        var sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("grimedrop2", ofType: "mp3")!);
        playerItem = AVPlayerItem(URL: sound)
        avplayer=AVPlayer(playerItem: playerItem!)
        let playerLayer=AVPlayerLayer(player: avplayer!)
        playerLayer.frame=CGRectMake(0, 0, 300, 50)
        self.view.layer.addSublayer(playerLayer)
        avplayer!.play()
        println("STOPPER IS RUNNING") // seems that if you stop a little bit it'll stop which shouldn't happen

    }

}