
//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/15.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit
import CoreData

class TweetersTableViewController: CoreDataTableViewController {
    
    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        if let context = managedObjectContext, mention != nil && !(mention?.isEmpty)! {
            let request: NSFetchRequest<NSFetchRequestResult> = TwitterUser.fetchRequest()
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "darkside")
            request.sortDescriptors = [NSSortDescriptor(key: "screenName",
                                                        ascending: true,
                                                        selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            ]
            fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: request ,
                                                                                        managedObjectContext: context,
                                                                                        sectionNameKeyPath: nil,
                                                                                        cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }
    
    private func tweetCountWithMention(by user: TwitterUser) -> Int? {
        var count: Int?
        user.managedObjectContext?.performAndWait {
            let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = try? user.managedObjectContext!.count(for: request)
        }
        
        return count
    }

    // MARK: - Table view data source
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUserCell", for: indexPath)
     
        // Configure the cell...
        if let twitterUser = fetchedResultsController?.object(at: indexPath) as? TwitterUser {
            var screenName: String?
            twitterUser.managedObjectContext?.performAndWait {
                screenName = twitterUser.screenName
            }
            cell.textLabel?.text = screenName
            if let count = tweetCountWithMention(by: twitterUser) {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
     
     return cell
     }
 
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     
    
}
