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
    
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let menu = NSMenu()
    let menuItemRepeat = NSMenuItem()
    let popovar = NSPopover()
    var popupViewController = NSViewController()
    var quitButton = NSButton()
    var selectButton = NSButton()
    var repeatButton = NSButton()
    var moviePlayTimeText = NSText()
    var seekBar = NSSlider()
    
 //   var isMovieRepeat = false
    
    func startMovie(fileURL: URL){
        let avAsset = AVURLAsset(url: fileURL)
        let Item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: Item)
        playerView.player = player
        player.play()
        seekBar.action = #selector(AppDelegate.onSeekbarValueChange)
        seekBar.minValue = 0
        seekBar.maxValue = CMTimeGetSeconds(avAsset.duration)
    }

    func onSeekbarValueChange(){
        let seekvarValue:Float64 = Float64(seekBar.floatValue)
        player.seek(to: CMTimeMakeWithSeconds(seekvarValue,Int32(NSEC_PER_SEC)))
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
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["mp4","mov","m4v"]
        let path = NSSearchPathForDirectoriesInDomains(.moviesDirectory, .userDomainMask, true)[0] as String
        let url:URL = NSURL(fileURLWithPath: path) as URL
        openPanel.directoryURL = url;
        openPanel.begin { (result) -> Void in
            if result == NSFileHandlingPanelOKButton { // ファイルを選択したか(OKを押したか)
                guard let url = openPanel.url else { return }
                self.startMovie(fileURL: url)
                print(url.absoluteString)
                // ここでファイルを読み込む
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
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popovar.performClose(sender)
    }

    
    func quit(){
        exit(0);
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setWindow()
        self.launchFinder()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                if(self.repeatButton.state == 1){
                    self.player.seek(to: kCMTimeZero)
                    self.player.play()
                }
            }
        })
        
        self.statusItem.title = "wallpaper!"
        
        if let button = self.statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        let frame = NSRect.init(x: 0, y: 0, width: 300, height: 200)
        let popupView = NSView.init(frame: frame)
        popupViewController.view = popupView
        
        quitButton = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        quitButton.frame.origin = NSPoint(x: frame.maxX-100, y: 180)
        quitButton.title = "quit"
        quitButton.action = #selector(AppDelegate.quit)
        popupView.addSubview(quitButton)
        (quitButton.cell as! NSButtonCell).backgroundColor = NSColor.red
        
        selectButton = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        selectButton.frame.origin = NSPoint(x: 0, y: 180)
        selectButton.title = "select"
        selectButton.action = #selector(AppDelegate.launchFinder)
        popupView.addSubview(selectButton)
        
        seekBar = NSSlider(frame: NSRect(x: 0, y: 0, width: frame.maxX - 100, height : 20))
        seekBar.frame.origin = NSPoint(x: 0, y: 10)
       // seekBar.addTarget(self, action: "onSliderValueChange:", forControlEvents: UIControlEvents.ValueChanged)
        popupView.addSubview(seekBar)
        
        repeatButton = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        repeatButton.title = "repeat"
        repeatButton.setButtonType(NSSwitchButton)
        repeatButton.state = 0
      //  repeatButton.action = #selector(AppDelegate.setRepeatMovie)
       // print(repeatButton.cell?.type)
        repeatButton.frame.origin = NSPoint(x: 200, y: 10)
        popupView.addSubview(repeatButton)
        
        popovar.contentViewController = popupViewController
        
     /*   self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        
        let menuItemSelect = NSMenuItem()
        menuItemSelect.title = "select"
        menuItemSelect.action = #selector(AppDelegate.launchFinder)
        menu.addItem(menuItemSelect)
        
        menuItemRepeat.title = "repeat"
        menuItemRepeat.action = #selector(AppDelegate.setRepeatMovie)
        menu.addItem(menuItemRepeat)
        
        let menuItemQuit = NSMenuItem()
        menuItemQuit.title = "quit"
        menuItemQuit.action = #selector(AppDelegate.quit)
        menu.addItem(menuItemQuit)
      */
        
    }
  
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}



