//
//  SoundManager.swift
//  iPrescription
//
//  Created by Marco Salafia on 25/08/15.
//  Copyright © 2015 Marco Salafia. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager : NSObject
{
    var alertSound: NSURL
    var audioPlayer: AVAudioPlayer? {
        
        get {
            let player: AVAudioPlayer?
            do
            {
                player = try AVAudioPlayer(contentsOfURL: alertSound)
            }
            catch _
            {
                player = nil
            }
            
            return player
        }
    }
    
    init(soundURL: NSURL)
    {
        self.alertSound = soundURL
        super.init()
    }
    
    convenience init(resource: String, ofType: String)
    {
        let soundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("chord", ofType: "m4r")!)
        self.init(soundURL: soundURL)
    }
    
    func playSound()
    {
        if let player = audioPlayer
        {
            player.prepareToPlay()
            player.play()
        }
    }
}