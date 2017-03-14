//
//  playViewController.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/03/10.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

class ModeView:NSView {
    
    func create(x:CGFloat,y:CGFloat,width:CGFloat, height:CGFloat) {
        self.frame = NSRect(x:x,y:y,width:width,height:height)
    }
    
    func hide() {
        self.removeFromSuperview()
    }
}

class MovieModeView:ModeView {
    let soundIcon = NSImage(named: "sound@2x.png")
    let startIcon = NSImage(named: "start@3x.png")
    let stopIcon = NSImage(named: "stop@3x.png")
    
    var selectButton = SuperButton()
    var runControllButton = SuperButton()
    var repeatButton = NSButton()
    var seekbarTimer = Timer()
    var seekBar = NSSlider()
    var moviePlayTimeText = Label()
    var muteButton = SuperButton()
    var volumeBar = NSSlider()
    
    var appDelegate:AppDelegate!
    
    func create(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, delegate: AppDelegate) {
        super.create(x: x, y: y, width: width, height: height)
        appDelegate = delegate
        selectButton.create(title:"select" ,x: 20, y: 50, width: 100, height: 20,action: #selector(appDelegate.launchFinder))
        selectButton.isBordered = false;
        selectButton.backgroundColor = NSColor.blue
        self.addSubview(selectButton)
        
        seekBar = NSSlider(frame: NSRect(x: 0, y: 30, width: frame.maxX - 60, height : 20))
        seekBar.target = self
        seekBar.action = #selector(onSeekbarValueChange)
        self.addSubview(seekBar)
        
        moviePlayTimeText.create(x: frame.maxX - 95 , y: 10, width: 40, height: 20,defaultText: "--:--")
        self.addSubview(moviePlayTimeText)
        
        muteButton.create(x:75,y:8,width:24,height:24,action:#selector(muteToggle),target: self)
        muteButton.image = soundIcon;
        muteButton.isBordered = false;
        muteButton.backgroundColor = NSColor.clear
        self.addSubview(muteButton)
        
        volumeBar = NSSlider(frame: NSRect(x: frame.maxX/2 - 45, y: 10, width: 100, height : 20))
        volumeBar.target = self
        volumeBar.action = #selector(onVolumeValueChange)
        volumeBar.minValue = 0
        volumeBar.maxValue = 1
        volumeBar.doubleValue = 0.5
        self.addSubview(volumeBar)
        
        repeatButton = NSButton(frame: NSRect(x: 0, y: 0, width: 60, height: 20))
        repeatButton.title = "repeat"
        repeatButton.setButtonType(NSSwitchButton)
        repeatButton.state = 0
        repeatButton.frame.origin = NSPoint(x: 10, y: 10)
        self.addSubview(repeatButton)
        
        runControllButton.create(x: frame.maxX - 53, y: 10, width: 43, height: 43,action:#selector(appDelegate.movieRunControll))
        runControllButton.image = startIcon;
        runControllButton.isBordered = false;
        runControllButton.backgroundColor = NSColor.clear
        self.addSubview(runControllButton)
    }
    
    func movieRunControll(){
        if (appDelegate.player.rate != 0.0) {
            runControllButton.image = stopIcon;
        } else {
            runControllButton.image = startIcon;
        }
    }
    
    func onSeekbarValueChange(){
        let seekbarValue:Float64 = Float64(seekBar.floatValue)
        appDelegate.player.seek(to: CMTimeMakeWithSeconds(seekbarValue,Int32(NSEC_PER_SEC)))
    }
    
    func onVolumeValueChange(){
        let volumebarValue:Float = Float(volumeBar.floatValue)
        appDelegate.player.volume = volumebarValue;
    }
    
    func muteToggle(){
        volumeBar.doubleValue = 0
        onVolumeValueChange()
    }
    
    func seekbarUpdate(){
        if (appDelegate.player.currentItem !== nil){
            let duration = CMTimeGetSeconds(appDelegate.player.currentItem!.duration)
            let time = CMTimeGetSeconds(appDelegate.player.currentTime())
            let value = Float(seekBar.maxValue - seekBar.minValue) * Float(time) / Float(duration) + Float(seekBar.minValue)
            seekBar.setValue(value, forKey: "value")
            
            let min = Int(time / 60)
            let sec = Int(time.truncatingRemainder(dividingBy: 60))
            moviePlayTimeText.text = String(format: "%02d:%02d",min, sec)
        }
    }
    
    func seekbarSet(){
        seekbarUpdate()
        seekbarTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.seekbarUpdate),
            userInfo: nil,
            repeats: true);
    }
    
    func seekbarStop(){
        seekbarTimer = Timer()
    }
}

class WebModeView: ModeView {
    
    var windowLevelChangeButton = SuperButton()
    var urlInput = NSTextField()
    var screenChangeButton = SuperButton()
    
    var appDelegate:AppDelegate!
    
    func create(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, delegate: AppDelegate) {
        super.create(x: x, y: y, width: width, height: height)
        appDelegate = delegate
        urlInput.frame = NSRect(x:10,y:20,width:width-20,height:20)
        urlInput.action = #selector(appDelegate.setUrl)
        self.addSubview(urlInput)
        
        windowLevelChangeButton.create(title: "toFront", x: frame.maxX-100, y: 40, width: 100, height: 20,action:#selector(appDelegate.windowLevelChange))
        windowLevelChangeButton.isBordered = false;
        self.addSubview(windowLevelChangeButton)
        windowLevelChangeButton.backgroundColor = NSColor.brown
        
        screenChangeButton.create(title: "screenChange",x: 10 , y: 50, width: 100, height: 20,action:#selector(appDelegate.screenChenge))
        screenChangeButton.backgroundColor = NSColor.darkGray
        screenChangeButton.isBordered = false
        self.addSubview(screenChangeButton)
        
    }
    
   
    
}
