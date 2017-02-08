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
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    let menu = NSMenu()
    let menuItemRepeat = NSMenuItem()
    let popover = NSPopover()
    var player = AVPlayer()
    var isMovieRepeat = false
    
    func startMovie(fileURL: URL){
        let avAsset = AVURLAsset(url: fileURL)
        let Item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: Item)
        playerView.player = player
        player.play()
    }
    
    func setWindow(){
        let screen = NSScreen.main()
        window.styleMask = NSWindowStyleMask.borderless
        window.level = Int(CGWindowLevelForKey(.desktopIconWindow))
        if let frame = screen?.frame  {
            let size = NSSize(width: frame.size.width, height: frame.size.height)
            let point = NSPoint(x: 0, y: 0)
            window.setFrameOrigin(point)
            window.setContentSize(size)
            //print(size)
        }
    }
    
    func launchFinder(){
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["mp4","m4a"]
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
      //  let workspace = NSWorkspace.shared()
       
    }
    
    func setRepeatMovie(){
        isMovieRepeat = !isMovieRepeat
        if(isMovieRepeat){
            menuItemRepeat.title = "repeat ✔︎"
        }else{
            menuItemRepeat.title = "repeat"
        }
    }
    
    func quit(){
        exit(0);
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.setWindow()
        self.launchFinder()
        
        self.statusItem.title = "wallpaper!"
        self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                if(self.isMovieRepeat){
                    self.player.seek(to: kCMTimeZero)
                    self.player.play()
                }
            }
        })
        
       /* if let button = self.statusItem.button {
            button.title = "pop up!";
            button.action = #selector(AppDelegate.togglePopover)
            print("pop")
        }*/
        
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
    
      //  popover.contentViewController = NSTabViewController(nibName: "QuotesViewController", bundle: nil)
        
       
    }
    
    func showPopover() {
        if let button = self.statusItem.button {
            
            print(button.bounds)
            popover.show(relativeTo:button.bounds , of: button, preferredEdge:  NSRectEdge.minY)
        }
    }
    
    func closePopover() {
     //   popover.performClose(sender)
    }
    
    func togglePopover() {
        print("hoge")
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
  
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}



