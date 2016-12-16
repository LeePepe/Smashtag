//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/11/24.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UISearchBarDelegate {
    // MARK: - Model
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var tweets = [Array<Twitter.Tweet>]() { didSet { tableView.reloadData() } }
    
    var searchText: String? {
        didSet {
            searchBar?.text = searchText
            lastTwitterRequest = nil
            tweets.removeAll()
            searchForTweets()
            title = searchText
            // store in NSUserDefaults
            if let termText = searchText, !termText.isEmpty {
                let defaults = UserDefaults.standard
                var terms = [String: Date]()
                if let recentTerms = defaults.dictionary(forKey: UserDefaultKeyWordOfRecentSearch) as? [String: Date] {
                    terms = recentTerms
                }
                terms[termText] = Date()
                defaults.set(terms, forKey: UserDefaultKeyWordOfRecentSearch)
                defaults.synchronize()
            }
        }
    }
    
    // MARK: - Outlet
    @IBAction func refresh(_ sender: UIRefreshControl?) {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                            weakSelf?.updateDatebase(newTweets: newTweets)
                        }
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }


    // MARK: - Twitter request
    
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText , !query.isEmpty {
                if query.hasPrefix("@") {
                    return Twitter.Request(search: query + " OR from:\(query.substring(from: query.index(after: query.startIndex))) -filter:retweets", count: 100)
                } else {
                    return Twitter.Request(search: query + "-filter:retweets", count: 100)
                }
            } else {
                return nil
            }
        } else {
            return lastTwitterRequest!.requestForNewer
        }
        
    }
    private var lastTwitterRequest: Twitter.Request? { didSet { print("have last twitter request: \(lastTwitterRequest)") } } 
    
    private func updateDatebase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.perform {
            for twitterInfo in newTweets {
                // create a new, unique Tweet with that Twitter info
                _ = Tweet.save(WithTwitterInfo: twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                NSLog("Core Data Error: \(error)")
            }
        }
        printDatabaseStatistics()
        print("done printing database statistics")
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.perform {
            if let results = try? self.managedObjectContext!.fetch(NSFetchRequest<TwitterUser>(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            let tweetCount = try! self.managedObjectContext!.count(for: Tweet.fetchRequest())
            print("\(tweetCount) Tweets")
        }
    }
    
    private func searchForTweets() {
        refresh(refreshControl)
    }
    
    // MARK: - Search Bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
    }
        
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowTweetMentionSegueIdentifier = "Show Mentions"
        static let SearchMentionUnwindSegueIdentifier = "Search Mention"
        static let ShowSearchMediaSegueIdentifier = "ShowAllMedia"
        static let TweeterUserSearchTermSegueIdentifier = "TweeterUserSearch"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowTweetMentionSegueIdentifier:
                if let tweetDetailTVC = segue.destination as? TweetDetailTableViewController {
                    if let tweet = (sender as? TweetTableViewCell)?.tweet {
                        tweetDetailTVC.tweet = tweet
                        tweetDetailTVC.title = tweet.user.name
                    }
                }
            case Storyboard.ShowSearchMediaSegueIdentifier:
                if let imageCVC = segue.destination.content as? TweetImageCollectionViewController {
                    var mediaWithTweet = Array<(Twitter.MediaItem, Twitter.Tweet)>()
                    for tweets in self.tweets {
                        for tweet in tweets {
                            for media in tweet.media {
                                mediaWithTweet.append((media, tweet))
                            }
                        }
                    }
                    imageCVC.mediaWithTweet = mediaWithTweet
                }
            case Storyboard.TweeterUserSearchTermSegueIdentifier:
                if let tweetersTVC = segue.destination as? TweetersTableViewController {
                    tweetersTVC.mention = searchText
                    tweetersTVC.managedObjectContext = managedObjectContext
                }
            default:
                
                break
            }
        }
    }
    
    @IBAction func perpare(forUnwind segue: UIStoryboardSegue) {
    }
}

extension UIViewController {
    var content: UIViewController {
        if let nav = self as? UINavigationController {
            return nav.visibleViewController ?? self
        } else {
            return self
        }
    }
}

