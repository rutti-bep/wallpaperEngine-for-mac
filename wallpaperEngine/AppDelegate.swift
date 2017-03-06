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
    
    var playlist = PlayList();
    
    let openPanel = NSOpenPanel()
    
    var popupView = NSView()
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let menu = NSMenu()
    let menuItemRepeat = NSMenuItem()
    let popovar = NSPopover()
    var popupViewController = NSViewController()
    var quitButton = SuperButton()
    var selectButton = SuperButton()
    var runControllButton = SuperButton()
    var repeatButton = NSButton()
    var seekbarTimer = Timer()
    var seekBar = NSSlider()
    var moviePlayTimeText = Label()
    var muteButton = SuperButton()
    var volumeBar = NSSlider()
    
    let menubarIcon = NSImage(named: "icon.png")
    let soundIcon = NSImage(named: "sound@2x.png")
    let startIcon = NSImage(named: "start@3x.png")
    let stopIcon = NSImage(named: "stop@3x.png")
    
    func setMovie(){
        guard let filePath = playlist.playlist[playlist.selector]["path"] else {
            return
        }
        let avAsset = AVURLAsset(url: filePath as! URL)
        let Item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: Item)
        playerView.player = player
        seekBar.action = #selector(AppDelegate.onSeekbarValueChange)
        seekBar.minValue = 0
        seekBar.maxValue = CMTimeGetSeconds(avAsset.duration)
        if(player.rate == 0.0){
            movieRunControll()
        }
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
            moviePlayTimeText.text = String(format: "%02d:%02d",min, sec)
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
            if result == NSFileHandlingPanelOKButton {
                guard let url = self.openPanel.url else { return }
                self.playlist.add(filePath: url)
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
                self.playlist.selector += 1;
                if(self.playlist.playlist.count == self.playlist.selector){
                    self.playlist.selector = 0;
                    if (self.repeatButton.state == 1){
                        self.player.seek(to: kCMTimeZero)
                        self.setMovie()
                    }
                }else{
                    self.setMovie();
                }
                self.playlist.drawView()
            }
        })
        
        //self.statusItem.button?.image = menubarIcon;
        
        if let button = self.statusItem.button {
            button.image = menubarIcon
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        let frame = NSRect.init(x: 0, y: 0, width: 300, height: 200)
        popupView = NSView.init(frame: frame)
        popupViewController.view = popupView
        
        playlist.create(x: 10, y: 60, width: 280, height: 100)
        playlist.setUp();
        //playerView = NSView(frame: playlistFrame)
        popupView.addSubview(playlist)
        
        quitButton.create(x: frame.maxX-100, y: 180, width: 100, height: 20,action:#selector(AppDelegate.quit))
        quitButton.title = "quit"
        quitButton.isBordered = false;
        popupView.addSubview(quitButton)
        quitButton.backgroundColor = NSColor.red
        
        selectButton.create(x: 0, y: 180, width: 100, height: 20,action: #selector(AppDelegate.launchFinder))
        selectButton.title = "select"
        selectButton.isBordered = false;
        selectButton.backgroundColor = NSColor.blue
        popupView.addSubview(selectButton)
        
        seekBar = NSSlider(frame: NSRect(x: 0, y: 30, width: frame.maxX - 60, height : 20))
        popupView.addSubview(seekBar)
        
        moviePlayTimeText.create(x: frame.maxX - 85 , y: 10, width: 50, height: 20,defaultText: "--:--")
        popupView.addSubview(moviePlayTimeText)
        
        muteButton.create(x:80,y:8,width:24,height:24,action:#selector(AppDelegate.muteToggle))
        muteButton.image = soundIcon;
        muteButton.isBordered = false;
        muteButton.backgroundColor = NSColor.clear
        popupView.addSubview(muteButton)
        
        volumeBar = NSSlider(frame: NSRect(x: frame.maxX/2 - 40, y: 10, width: 100, height : 20))
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
        
        runControllButton.create(x: frame.maxX - 43, y: 10, width: 43, height: 43,action:#selector(AppDelegate.movieRunControll))
        runControllButton.image = startIcon;
        runControllButton.isBordered = false;
        runControllButton.backgroundColor = NSColor.clear
        popupView.addSubview(runControllButton)
        
        
        popovar.contentViewController = popupViewController
        
    }
  
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}



