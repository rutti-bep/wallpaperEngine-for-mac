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
import Foundation
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let imageUrls = ["/Users/konnosatoru/Downloads/Cg5A7_7U0AAWpwA.jpg",
                     "/Users/konnosatoru/Downloads/graphic23_l.png"
    ];
    var count = 0;
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var wallpaperTimer = Timer.scheduledTimer(
            timeInterval: 0.03,
            target: self,
            selector: Selector("wallpaperChange"),
            userInfo: nil,
            repeats: true);
    }
    
    func wallpaperChange(){
        count += 1;
        if(count > imageUrls.count-1){
            count = 0;
        }
        print(count)
        do {
            let imgurl = NSURL.fileURL(withPath: imageUrls[count])
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



