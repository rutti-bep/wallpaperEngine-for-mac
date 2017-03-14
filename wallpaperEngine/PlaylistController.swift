//
//  PlaylistController.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/22.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Foundation
import AppKit

class PlayList: NSScrollView{
    typealias MovieData = Dictionary<String,Any>
    var playlist:[MovieData] = []
    var selector = 0;
    
    var viewSize:NSRect?;
    var playlistViewSize:NSRect?
    let defaultLabelCount = 5;
    
    var playlistView = NSView();
    var playlistViewLabel:[PlayListButton] = []
    var viewSelector = 0;
    
    func create(x:CGFloat,y:CGFloat,width:CGFloat, height:CGFloat){
        playlistViewSize = NSRect(x: 0,y: 0,width: width, height: (height/CGFloat(defaultLabelCount))*CGFloat(minimumGuarantee(playlist.count)))
        playlistView.frame = playlistViewSize!;
        self.documentView = playlistView
        self.drawsBackground = false
        viewSize = NSRect(x: x,y: y,width: width, height: height)
        self.hasVerticalScroller = true;
        self.contentView.scroll(NSPoint(x:0,y:(playlistViewSize?.height)!))
        self.frame = viewSize!;
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
    
    func replace(from:Int, at:Int){
        if selector == from {
            if(from+at >= playlist.count){
                selector = playlist.count-1
            }else if (from+at < 0){
                selector = 0
            }else{
                selector = from+at
            }
        } else if at < 0 && from > selector && from+at <= selector{
            selector += 1
        } else if at > 0 && from < selector && from+at >= selector{
            selector -= 1
        }
        
        let replaceItem = playlist[from]
        playlist.remove(at: from)
        if (from+at >= playlist.count){
            playlist += [replaceItem]
        } else if(from+at < 0){
            self.playlist.insert(replaceItem, at: 0)
        } else {
            self.playlist.insert(replaceItem, at: from+at)
        }
        
        drawView()
    }
    
    func deleteItem(_ at:Int){
        playlist.remove(at: at)
        if selector > at {
            selector -= 1
        }
        drawView()
    }
    
    func increment(_ sender: SuperButton){
        if playlist.count >= defaultLabelCount{
            self.viewSelector += sender.tag;
            if playlist.count <= viewSelector+defaultLabelCount {
                viewSelector = playlist.count-defaultLabelCount
            }
            if 0 >= viewSelector {
                viewSelector = 0
            }
            self.drawView()
        }
    }
    
    func movieJump(_ sender: SuperButton){
        self.selector = sender.tag;
        let appDelegate:AppDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.setMovie();
        self.drawView()
    }
    
    func drawView(){
        playlistViewSize = NSRect(x: 0,y: 0,width: (playlistViewSize?.width)!, height: CGFloat(((viewSize?.height)!/CGFloat(defaultLabelCount))*CGFloat(minimumGuarantee(playlist.count))))
        playlistView.frame = playlistViewSize!;
        while playlistViewLabel.count != 0 {
            playlistViewLabel[0].removeFromSuperview()
            playlistViewLabel.remove(at: 0)
        }
        if(playlist.count >= 0){
            if(playlist.count <= viewSelector){
                selector = 0;
            }
            for i in 0..<playlist.count {
                if(playlist[i]["path"] != nil){
                    let playlistLabel = PlayListButton();
                    playlistLabel.create(x:0,y:((playlistViewSize?.height)!-(((viewSize?.height)!/CGFloat(defaultLabelCount))*CGFloat(i+1))),width:(viewSize?.width)!,height:((viewSize?.height)!/CGFloat(defaultLabelCount)))
                    playlistLabel.title = playlist[i]["name"] as! String
                    playlistLabel.target = self
                    playlistLabel.tag = i
                    playlistLabel.action = #selector(self.movieJump(_:))
                    if i == selector {
                        playlistLabel.backgroundColor = NSColor.red
                    } else {
                        playlistLabel.backgroundColor = NSColor.clear
                    }
                    playlistViewLabel.append(playlistLabel)
                    playlistView.addSubview(playlistViewLabel[i])
                    
                }
            }
        }
    }
    
    func minimumGuarantee (_ value:Int) -> Int{
        var returnValue = 0;
        if (value > defaultLabelCount){
            returnValue = value
        }else{
            returnValue = defaultLabelCount
        }
        return returnValue
    }
    
}

class PlayListButton: SuperButton {
    var stockPositionX:CGFloat?;
    var stockPositionY:CGFloat?;
   // var parent:PlayList?;
    
    override func mouseDown(with theEvent: NSEvent) {
        self.target?.playlistView.addSubview(self)
        stockPositionX = self.frame.origin.x
        stockPositionY = self.frame.origin.y
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if(Float(self.frame.width/2) < fabs(Float(self.frame.origin.x)-Float(stockPositionX!))){
            self.target?.deleteItem(self.tag)
        } else if(self.frame.origin.x == stockPositionX && self.frame.origin.y == stockPositionY){
            super.mouseDown(with: theEvent)
        } else {
            self.target?.replace(from: self.tag, at: Int((stockPositionY!-self.frame.origin.y)/CGFloat(self.frame.height)))
        }
    }
    
    override func mouseDragged(with theEvent: NSEvent){
        self.frame.origin.x += theEvent.deltaX
        self.frame.origin.y -= theEvent.deltaY
    }
}



