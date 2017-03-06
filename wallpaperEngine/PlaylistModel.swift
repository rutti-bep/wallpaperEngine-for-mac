//
//  Playlist+CoreDataProperties.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/17.
//  Copyright © 2017年 今野暁. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Playlist)
class Playlist: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist");
    }

    @NSManaged public var filePath: Int16
    @NSManaged public var id: Int16

}
