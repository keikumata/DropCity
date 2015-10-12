//
//  TempController.swift
//  Drop
//
//  Created by Kei Yoshikoshi on 10/9/15.
//  Copyright (c) 2015 Drop. All rights reserved.
//

import UIKit
import AVFoundation
class TempController: UIViewController {
    var audioPlayer = AVAudioPlayer()

    @IBAction func DropButtonAction(sender: UIButton) {
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("grimedropsecond", ofType: "mp3")!);
        audioPlayer.stop()
        // audioPlayer stuff
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            
        }
        
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        audioPlayer.play()
    }
    @IBAction func PlayButtonAction(sender: UIButton) {
        audioPlayer.play()
    }
    @IBOutlet weak var DropButton: UIButton!
    @IBOutlet weak var PlayButotn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jb", ofType: "mp3")!);
        
        // audioPlayer stuff
        do {
             audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
        } catch {
            
        }
       
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
