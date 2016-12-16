//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/11.
//  Copyright © 2016年 lee. All rights reserved.
//

import Foundation
import CoreData


extension Tweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tweet> {
        return NSFetchRequest<Tweet>(entityName: "Tweet")
    }

    @NSManaged public var posted: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var unique: String?
    @NSManaged public var tweeter: TwitterUser?

}
