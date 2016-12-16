//
//  TwitterUser+CoreDataClass.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/11.
//  Copyright © 2016年 lee. All rights reserved.
//

import Foundation
import CoreData
import Twitter

@objc(TwitterUser)
public class TwitterUser: NSManagedObject {
    
    public class func save(WithTwitterInfo twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
        let request: NSFetchRequest<TwitterUser> = fetchRequest()//NSFetchRequest<TwitterUser>(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        
        if let user = (try? context.fetch(request))?.first {
            return user
        } else if let user = NSEntityDescription.insertNewObject(forEntityName: "TwitterUser", into: context) as? TwitterUser {
            user.screenName = twitterInfo.screenName
            user.name = twitterInfo.name
            return user
        }
        return nil
    }
}
