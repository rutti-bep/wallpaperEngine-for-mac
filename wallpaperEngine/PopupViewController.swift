//
//  PopupViewController.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/22.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

class SuperButton: NSButton {
    func create(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat,action:Selector? = nil){
        self.frame = NSRect(x:x,y:y,width:width,height:height)
        self.action = action
        //self.target = self
    }
    
    var backgroundColor: NSColor {
        get {
            return (self.cell as! NSButtonCell).backgroundColor!
        }
        
        set {
            (self.cell as! NSButtonCell).backgroundColor = newValue
        }
    }
}

class Label: NSTextField {
    var text: String {
        get {
            return self.placeholderString!
        }
        
        set {
            self.placeholderString = newValue        }
    }
    func create(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat,defaultText:String){
        self.frame = NSRect(x:x,y:y,width:width,height:height);
        self.placeholderString = defaultText;
        self.allowsEditingTextAttributes = false;
        self.drawsBackground = false;
        self.isBordered = false;
        self.isEditable = false;
        self.isSelectable = false;
    }
}
