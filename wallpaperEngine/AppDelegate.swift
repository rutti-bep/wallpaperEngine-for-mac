//
//  AppDelegate.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/06.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Cocoa
import AppKit
import AVKit
import Foundation
import AVFoundation


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playerView: AVPlayerView!
    var player = AVPlayer()
    
    let openPanel = NSOpenPanel()
    
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let menu = NSMenu()
    let menuItemRepeat = NSMenuItem()
    let popovar = NSPopover()
    var popupViewController = NSViewController()
    var quitButton = NSButton()
    var selectButton = NSButton()
    var runControllButton = NSButton()
    var repeatButton = NSButton()
    var seekbarTimer = Timer()
    var seekBar = NSSlider()
    var moviePlayTimeText = NSTextField()
    var muteButton = NSButton()
    var volumeBar = NSSlider()
    
    let menubarIcon = NSImage(named: "icon.png")
    let soundIcon = NSImage(named: "sound@2x.png")
    let startIcon = NSImage(named: "start@3x.png")
    let stopIcon = NSImage(named: "stop@3x.png")
    
    func setMovie(fileURL: URL){
        let avAsset = AVURLAsset(url: fileURL)
        let Item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: Item)
        playerView.player = player
        seekBar.action = #selector(AppDelegate.onSeekbarValueChange)
        seekBar.minValue = 0
        seekBar.maxValue = CMTimeGetSeconds(avAsset.duration)
        movieRunControll()
        onVolumeValueChange()
    }

    func movieRunControll(){
        if (player.rate == 0.0) {
            player.play()
            runControllButton.image = stopIcon;
        } else {
            player.pause()
            runControllButton.image = startIcon;
        }
    }
    
    func onSeekbarValueChange(){
        let seekbarValue:Float64 = Float64(seekBar.floatValue)
        player.seek(to: CMTimeMakeWithSeconds(seekbarValue,Int32(NSEC_PER_SEC)))
    }
    
    func onVolumeValueChange(){
        let volumebarValue:Float = Float(volumeBar.floatValue)
        player.volume = volumebarValue;
    }
    
    func muteToggle(){
        volumeBar.doubleValue = 0
        onVolumeValueChange()
    }
    
    func seekbarUpdate(){
        if (self.player.currentItem !== nil){
            let duration = CMTimeGetSeconds(self.player.currentItem!.duration)
            let time = CMTimeGetSeconds(self.player.currentTime())
            let value = Float(seekBar.maxValue - seekBar.minValue) * Float(time) / Float(duration) + Float(seekBar.minValue)
            seekBar.setValue(value, forKey: "value")
            
            let min = Int(time / 60)
            let sec = Int(time.truncatingRemainder(dividingBy: 60))
            moviePlayTimeText.placeholderString = String(format: "%02d:%02d",min, sec)
        }
    }
    
    func setWindow(){
        let screen = NSScreen.main()
        window.styleMask = NSWindowStyleMask.borderless
        window.level = Int(CGWindowLevelForKey(.desktopWindow))
        window.collectionBehavior = NSWindowCollectionBehavior.canJoinAllSpaces
        
        if let frame = screen?.frame  {
            let size = NSSize(width: frame.size.width, height: frame.size.height)
            let point = NSPoint(x: 0, y: 0)
            window.setFrameOrigin(point)
            window.setContentSize(size)
        }
        
    }
    
    func launchFinder(){
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["mp4","mov","m4v"]
        openPanel.level = Int(CGWindowLevelForKey(.floatingWindow))
        let path = NSSearchPathForDirectoriesInDomains(.moviesDirectory, .userDomainMask, true)[0] as String
        let url:URL = NSURL(fileURLWithPath: path) as URL
        openPanel.directoryURL = url;
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {                 guard let url = self.openPanel.url else { return }
                self.setMovie(fileURL: url)
                //print(url.absoluteString)
            }
            
        }
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popovar.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popovar.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            seekbarUpdate()
            seekbarTimer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(AppDelegate.seekbarUpdate),
                userInfo: nil,
                repeats: true);
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popovar.performClose(sender)
        seekbarTimer = Timer()
    }

    func quit(){
        exit(0);
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setWindow()
        self.launchFinder()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                if (self.repeatButton.state == 1){
                    self.player.seek(to: kCMTimeZero)
                    self.player.play()
                } else {
                    self.runControllButton.title = "start"
                }
            }
        })
        
        //self.statusItem.button?.image = menubarIcon;
        
        if let button = self.statusItem.button {
            button.image = menubarIcon
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        let frame = NSRect.init(x: 0, y: 0, width: 300, height: 200)
        let popupView = NSView.init(frame: frame)
        popupViewController.view = popupView
        
        quitButton = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        quitButton.frame.origin = NSPoint(x: frame.maxX-100, y: 180)
        quitButton.title = "quit"
        quitButton.isBordered = false;
        quitButton.action = #selector(AppDelegate.quit)
        popupView.addSubview(quitButton)
        (quitButton.cell as! NSButtonCell).backgroundColor = NSColor.red
        
        selectButton = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        selectButton.frame.origin = NSPoint(x: 0, y: 180)
        selectButton.title = "select"
        selectButton.isBordered = false;
        (selectButton.cell as! NSButtonCell).backgroundColor = NSColor.blue
        selectButton.action = #selector(AppDelegate.launchFinder)
        popupView.addSubview(selectButton)
        
        seekBar = NSSlider(frame: NSRect(x: 0, y: 0, width: frame.maxX - 40, height : 20))
        seekBar.frame.origin = NSPoint(x: 0, y: 30)
        popupView.addSubview(seekBar)
        
        moviePlayTimeText = NSTextField(frame: NSRect(x: 0, y: 0, width: 50, height: 20))
        moviePlayTimeText.frame.origin = NSPoint(x: frame.maxX - 85 , y: 10)
        moviePlayTimeText.allowsEditingTextAttributes = false
        moviePlayTimeText.drawsBackground = false;
        moviePlayTimeText.isBordered = false;
        moviePlayTimeText.isEditable = false;
        moviePlayTimeText.isSelectable = false;
        moviePlayTimeText.placeholderString = "--:--"
        popupView.addSubview(moviePlayTimeText)
        
        muteButton = NSButton(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
        muteButton.frame.origin = NSPoint(x: 80, y: 8)
        muteButton.image = soundIcon;
        muteButton.isBordered = false;
        (muteButton.cell as! NSButtonCell).backgroundColor = NSColor.clear
        muteButton.action = #selector(AppDelegate.muteToggle)
        popupView.addSubview(muteButton)
        
        volumeBar = NSSlider(frame: NSRect(x: 0, y: 0, width: 100, height : 20))
        volumeBar.frame.origin = NSPoint(x: frame.maxX/2 - 40, y: 10)
        volumeBar.action = #selector(AppDelegate.onVolumeValueChange)
        volumeBar.minValue = 0
        volumeBar.maxValue = 1
        volumeBar.doubleValue = 0.5
        popupView.addSubview(volumeBar)
        
        repeatButton = NSButton(frame: NSRect(x: 0, y: 0, width: 60, height: 20))
        repeatButton.title = "repeat"
        repeatButton.setButtonType(NSSwitchButton)
        repeatButton.state = 0
        repeatButton.frame.origin = NSPoint(x: 10, y: 10)
        popupView.addSubview(repeatButton)
        
        runControllButton = NSButton(frame: NSRect(x: 0, y: 0, width: 43, height: 43))
        runControllButton.frame.origin = NSPoint(x: frame.maxX - 43, y: 10)
        runControllButton.image = startIcon;
        runControllButton.isBordered = false;
        (runControllButton.cell as! NSButtonCell).backgroundColor = NSColor.clear
        runControllButton.action = #selector(AppDelegate.movieRunControll)
        popupView.addSubview(runControllButton)
        
        
        popovar.contentViewController = popupViewController
        
    }
  
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}



