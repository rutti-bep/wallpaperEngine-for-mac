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
import WebKit
import Foundation
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{
    
    var windows:[NSWindow] = [];
    
    var webView = WKWebView()
    
    var playerView = AVPlayerView()
    var player = AVPlayer()
    
    var playlist = PlayList();
    
    let openPanel = NSOpenPanel()
    
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    
    let popovar = NSPopover()
    var popupView = NSView()
    var popupViewController = NSViewController()
    
    var movieModeButton = SuperButton()
    var webModeButton = SuperButton()
    var quitButton = SuperButton()
    
    var movieModeView = MovieModeView()
    
    var webModeView = WebModeView()
    
    let menubarIcon = NSImage(named: "icon.png")
    
    func movieMode(){
        webView.stopLoading()
        webView.reload()
        
        webView.removeFromSuperview()
        webModeView.hide()
        
        for i in 0..<windows.count {
            windows[i].contentView?.addSubview(playerView)
        }
        popupView.addSubview(movieModeView)
        popupView.addSubview(playlist)
    }
    
    func webMode(){
        if(player.rate != 0.0){
            player.pause()
        }
        
        playerView.removeFromSuperview()
        playlist.removeFromSuperview()
        movieModeView.hide()
        
        windows[windows.count-1].contentView?.addSubview(webView)
        //        for i in 0..<windows.count {
        //            windows[i].contentView?.addSubview(webView)
        //        }
        popupView.addSubview(webModeView)
    }
    
    func setMovie(){
        guard let filePath = playlist.playlist[playlist.selector]["path"] else {
            return
        }
        let avAsset = AVURLAsset(url: filePath as! URL)
        let Item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: Item)
        playerView.player = player
        movieModeView.seekBar.minValue = 0
        movieModeView.seekBar.maxValue = CMTimeGetSeconds(avAsset.duration)
        if(player.rate == 0.0){
            self.movieRunControll()
        }
        movieModeView.onVolumeValueChange()
    }
    
    func setUrl (){
        webView.stopLoading()
        let url = URL(string: webModeView.urlInput.stringValue)
        let req = URLRequest(url: url!)
        self.webView.load(req);
        print(url!)
    }
    
    func reload (){
        webView.reload()
    }
    
    func movieRunControll(){
        if (player.rate == 0.0) {
            player.play()
        } else {
            player.pause()
        }
        movieModeView.movieRunControll()
    }
    
    func setWindow(counter:Int,screen:NSScreen){
        let newWindow = windows[counter]
        newWindow.styleMask = NSWindowStyleMask.borderless
        newWindow.level = Int(CGWindowLevelForKey(.desktopWindow))
        newWindow.collectionBehavior = NSWindowCollectionBehavior.canJoinAllSpaces
        
        let frame = screen.frame
        let size = NSSize(width: frame.size.width, height: frame.size.height)
        let point = NSPoint(x: screen.frame.minX, y: screen.frame.minY)
        newWindow.setFrameOrigin(point)
        newWindow.setContentSize(size)
        
        playerView.frame.size = size
        webView.frame.size = size
        
        newWindow.makeKeyAndOrderFront(nil)
        windows[counter] = newWindow
        
    }
    
    func windowLevelChange(){
        for i in 0..<windows.count {
            if windows[i].level == Int(CGWindowLevelForKey(.desktopWindow)) {
                windows[i].styleMask = NSWindowStyleMask(rawValue: 15)
                windows[i].level = Int(CGWindowLevelForKey(.normalWindow))
                webView.frame.size = windows[i].frame.size
                webModeView.windowLevelChangeButton.title = "toBehind"
            } else {
                windows[i].styleMask = NSWindowStyleMask.borderless
                //            windows = []
                var screens = NSScreen.screens()
                let screensCount:Int = (screens?.count)!
                for i in 0..<screensCount {
                    self.setWindow(counter:i,screen:(screens?[i])!)
                }
                
            }
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
                print(url.absoluteString)
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
            movieModeView.seekbarSet()
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popovar.performClose(sender)
        movieModeView.seekbarStop()
    }
    
    func quit(){
        exit(0);
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //        windows = []
        var screens = NSScreen.screens()
        let screensCount:Int = (screens?.count)!
        for i in 0..<screensCount {
            let newWindow = NSWindow()
            windows.append(newWindow)
            self.setWindow(counter:i,screen:(screens?[i])!)
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                self.playlist.selector += 1;
                if(self.playlist.playlist.count <= self.playlist.selector){
                    self.playlist.selector = 0;
                    self.player.seek(to: kCMTimeZero)
                    if (self.movieModeView.repeatButton.state == 1 && self.playlist.playlist.count > 0){
                        self.setMovie()
                    }
                }else{
                    self.setMovie();
                }
                self.movieModeView.movieRunControll()
                self.playlist.drawView()
            }
        })
        
        if let button = self.statusItem.button {
            button.image = menubarIcon
            button.action = #selector(self.togglePopover(_:))
        }
        
        let frame = NSRect.init(x: 0, y: 0, width: 300, height: 220)
        popupView = NSView.init(frame: frame)
        popupViewController.view = popupView
        
        playlist.create(x: 10, y: 80, width: 280, height: 100)
        popupView.addSubview(playlist)
        
        
        
        quitButton.create(title: "quit" ,x: frame.maxX-100, y: frame.maxY-20, width: 100, height: 20,action:#selector(self.quit))
        quitButton.isBordered = false;
        popupView.addSubview(quitButton)
        quitButton.backgroundColor = NSColor.red
        
        movieModeButton.create(title:"movieMode", x: 0, y: frame.maxY-20, width: 100, height: 20,action:#selector(self.movieMode))
        movieModeButton.isBordered = false;
        movieModeButton.backgroundColor = NSColor.green
        popupView.addSubview(movieModeButton)
        
        webModeButton.create(title: "webMode",x: 100, y: frame.maxY-20, width: 100, height: 20,action:#selector(self.webMode))
        webModeButton.isBordered = false;
        webModeButton.backgroundColor = NSColor.cyan
        popupView.addSubview(webModeButton)
        
        movieModeView.create(x: 0, y: 0, width: frame.maxX, height: 70,delegate:self)
        webModeView.create(x: 0, y: 0, width: frame.maxX, height: 70,delegate:self)
        self.movieMode()
        
        popovar.contentViewController = popupViewController
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}



