//
//  Tweet+CoreDataClass.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/11.
//  Copyright © 2016年 lee. All rights reserved.
//

import Foundation
import CoreData
import Twitter

@objc(Tweet)
public class Tweet: NSManagedObject {

    public class func save(WithTwitterInfo twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        let request: NSFetchRequest<Tweet> = fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.fetch(request))?.first {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObject(forEntityName: "Tweet", into: context) as? Tweet {
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created as NSDate
            tweet.tweeter = TwitterUser.save(WithTwitterInfo: twitterInfo.user, inManagedObjectContext: context)
            return tweet
        }
        return nil
    }
}
