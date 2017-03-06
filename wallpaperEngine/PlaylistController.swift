//
//  PlaylistController.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/22.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Foundation
import AppKit

class PlayList: NSView{
    typealias MovieData = Dictionary<String,Any>
    var playlist:[MovieData] = []
    var selector = 0;
    
    var viewSize = NSRect(x:0,y:0,width:0,height:0)
    let defaultLabelCount = 6;
    
    var playlistViewLabel:[SuperButton] = []
    
    func create(x:CGFloat,y:CGFloat,width:CGFloat, height:CGFloat){
        viewSize = NSRect(x: x,y: y,width: width, height: height)
        self.frame = viewSize;
    }
    
    func add(filePath:URL){
        var movieData:MovieData = ["path": filePath];
        let pathArray = filePath.absoluteString.components(separatedBy: "/")
        let movieName = pathArray[(pathArray.count)-1]
        let encodeName = movieName.removingPercentEncoding;
        movieData["name"] = encodeName;
        playlist.append(movieData);
        self.drawView();
    }
    
    func remove(movieId:Int){
        
    }
    
    func increment(_ sender: SuperButton){
        self.selector += sender.tag;
        if playlist.count < selector {
            selector = 0
        }
        if 0 > selector {
            selector = playlist.count
        }
        self.drawView()
    }
    
    func movieJump(_ sender: SuperButton){
        self.selector = sender.tag;
        let appDelegate:AppDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.setMovie();
        self.drawView()
    }
    
    func drawView(){
        while playlistViewLabel.count != 0 {
            playlistViewLabel[0].removeFromSuperview()
            playlistViewLabel.remove(at: 0)
        }
        if(playlist.count >= 0){
            if(playlist.count <= selector){
                selector = 0;
            }
            for i in 0..<defaultLabelCount {
                Swift.print (playlist)
                if(playlist.count <= selector+i){
                    break;
                }
                if(playlist[selector+i]["path"] != nil){
                    let playlistLabel = SuperButton();
                    playlistLabel.create(x:0,y:(viewSize.height/CGFloat(defaultLabelCount))*CGFloat(defaultLabelCount-i-2),width:viewSize.width-30,height:(viewSize.height/CGFloat(defaultLabelCount)))
                    playlistLabel.title = playlist[selector+i]["name"] as! String
                    playlistLabel.target = self
                    playlistLabel.tag = selector+i
                    playlistLabel.action = #selector(PlayList.movieJump(_:))
                    playlistLabel.backgroundColor = NSColor.clear
                    playlistViewLabel.append(playlistLabel)
                    self.addSubview(playlistViewLabel[i])
                    
                }
            }
        }
    }
    
    func setUp(){
        let decrementButton = SuperButton();
        decrementButton.create(x:viewSize.width-30,y:(viewSize.height/CGFloat(defaultLabelCount))*CGFloat(defaultLabelCount-2),width:30,height:(viewSize.height/CGFloat(defaultLabelCount)))
        decrementButton.title = "mae"
        decrementButton.target = self
        decrementButton.tag = -1
        decrementButton.action = #selector(increment(_:))
        self.addSubview(decrementButton)

        let incrementButton = SuperButton();
        incrementButton.create(x:viewSize.width-30,y:(viewSize.height/CGFloat(defaultLabelCount))*CGFloat(defaultLabelCount-defaultLabelCount),width:30,height:(viewSize.height/CGFloat(defaultLabelCount)))
        incrementButton.title = "tugi"
        incrementButton.target = self
        incrementButton.tag = 1
        incrementButton.action = #selector(increment(_:))
        self.addSubview(incrementButton)
    }
}

