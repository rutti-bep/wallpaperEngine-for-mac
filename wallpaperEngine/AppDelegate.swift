//
//  AppDelegate.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/06.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Cocoa
//import Dispatch
//import CoreGraphics
import AppKit
import AVKit
import Foundation
import AVFoundation


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playerView: AVPlayerView!
    
    var imageUrls = [URL]();
   /*     "/Users/konnosatoru/Downloads/Cg5A7_7U0AAWpwA.jpg",
                     "/Users/konnosatoru/Downloads/graphic23_l.png"
    ];*/
    var imagesDir =  NSURL.fileURL(withPath: "/Users/konnosatoru/Desktop/wallpaper/");
    var count = 0;
    
    
    func start(){
        let documentsDirectoryURL =  NSURL.fileURL(withPath: "/Users/konnosatoru/Desktop/wallpaper/");
        var bool: ObjCBool = false
        if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool),bool.boolValue  {
            print("url is a folder url")
            do {
                let files = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: [])
                let picFiles = files.filter{ $0.pathExtension == "png" }
                for picUrl in picFiles{
                    imageUrls += [ picUrl ];
                    //print("file urls:",picUrl)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        start()
        let screen = NSScreen.main()
        
        // パスからassetを生成.
        let path = "/Users/konnosatoru/Movies/小林さんちのメイドラゴン/小林さんちのメイドラゴン OP.mp4"
        
        let fileURL: URL = NSURL.fileURL(withPath: path)
        print(fileURL)
        let avAsset = AVURLAsset(url: fileURL)
        // AVPlayerに再生させるアイテムを生成.
        let Item = AVPlayerItem(asset: avAsset)
        
        var player = AVPlayer(playerItem: Item)
        
        playerView.player = player
       
        player.play()
        
        window.level = Int(CGWindowLevelForKey(.desktopIconWindow))
        window.styleMask = NSBorderlessWindowMask
        if let frame = screen?.frame  {
            let size = NSSize(width: frame.size.width, height: frame.size.height)
            let point = NSPoint(x: 0, y: 0)
            window.setFrameOrigin(point)
            window.setContentSize(size)
            print(size)
        }
    /*    var wallpaperTimer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: Selector("wallpaperChange"),
            userInfo: nil,
            repeats: true);*/
    }
    
    func wallpaperChange(){
        count += 1;
        if(count > imageUrls.count-1){
            count = 0;
        }
        print(count)
        do {
            var imgurl = imageUrls[count];
            print (imgurl)
            let workspace = NSWorkspace.shared()
            if let screen = NSScreen.main()  {
                try workspace.setDesktopImageURL(imgurl, for: screen, options: [:])
            }
        } catch {
            print(error)
        }
    }

        /*var text = "Hello, World!";
        var display: CGDirectDisplayID = CGMainDisplayID(); // 1
        var err: CGError = CGDisplayCapture (display); // 2
       // if (Int(err) != Int(kCGErrorSuccess.value)){
            var ctx: CGContext = CGDisplayGetDrawingContext (display)!; // 3
         //   if (ctx != NULL){
               // CGContextSelectFont (ctx, "Times-Roman", 48, kCGEncodingMacRoman);
                //CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
                ctx.setFillColor (red: 0.3, green: 0.3, blue: 0.3, alpha: 1);
                ctx.setStrokeColor (red: 1, green: 1, blue: 1, alpha: 1);
               // CGContextShowTextAtPoint (ctx, 40, 40, text, text.characters.count); // 4
                sleep (4); // 5
         //   }
            CGDisplayRelease (display); // 6
       // }*/
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}



