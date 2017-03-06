//
//  Playlists+CoreDataProperties.swift
//  wallpaperEngine
//
//  Created by 今野暁 on 2017/02/17.
//  Copyright © 2017年 今野暁. All rights reserved.
//

import Foundation
import CoreData


extension Playlists {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlists> {
        return NSFetchRequest<Playlists>(entityName: "Playlists");
    }

    @NSManaged public var id: Int64
    @NSManaged public var path: String?

}
