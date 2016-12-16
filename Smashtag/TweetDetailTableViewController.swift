//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/11/26.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailTableViewController: UITableViewController {

    var tweet: Twitter.Tweet! {
        didSet {
            tweetInfo.removeAll()
            tweetInfo.append([Info.tweet(tweet)])
            tweetInfo.append(tweet.media.map { Info.image($0)})
            tweetInfo.append([Info.user("@\(tweet.user.screenName)")] + tweet.userMentions.map { Info.user($0.keyword) })
            tweetInfo.append(tweet.urls.map { Info.url($0.keyword)})
            tweetInfo.append(tweet.hashtags.map { Info.hashtag($0.keyword)})
        }
    }
    
    private var tweetInfo = [[Info]]()
    
    private enum Info {
        case tweet(Twitter.Tweet)
        case image(Twitter.MediaItem)
        case hashtag(String)
        case user(String)
        case url(String)
        
        var title: String? {
            switch self {
            case .image(_): return "Images"
            case .hashtag(_): return "Hashtags"
            case .url(_): return "URLs"
            case .user(_): return "Users"
            case .tweet(_): return nil
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweetInfo.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetInfo[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetInfo[section].first?.title
    }

    private struct Storyboard {
        static let ImageCellIdentifier = "Image"
        static let MentionCellIdentifier = "Mention"
        static let SearchMentionSegueIdentifier = "Search Mention"
        static let ShowImageSegueIdentifier = "Show Image"
        static let OpenUrlInWebViewSegueIdentifier = "Open URL"
        static let TweetCellIdentifier = "Tweet"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tweetInfo[indexPath.section][indexPath.row] {
        case .image(let media):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCellIdentifier, for: indexPath)
            if let imageCell = cell as? TweetDetailImageTableViewCell {
                imageCell.media = media
            }
            return cell
        case .hashtag(let mention), .url(let mention), .user(let mention):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MentionCellIdentifier, for: indexPath)
            cell.textLabel?.text = mention
            return cell
        case .tweet(let tweet):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
            if let tweetCell = cell as? TweetDetailTweetTableViewCell {
                tweetCell.tweet = tweet
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tweetInfo[indexPath.section][indexPath.row] {
        case .image(let media): return tableView.bounds.width / CGFloat(media.aspectRatio)
        default: return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tweetInfo[indexPath.section][indexPath.row] {
        case .hashtag(_), .user(_):
            performSegue(withIdentifier: Storyboard.SearchMentionSegueIdentifier, sender: tableView.cellForRow(at: indexPath))
        case .url(_):
//            if let url = URL(string: mention) {
                // Extra Task
                performSegue(withIdentifier: Storyboard.OpenUrlInWebViewSegueIdentifier, sender: tableView.cellForRow(at: indexPath))
                
                
                // Required Task
                // UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                let alert = UIAlertController(title: "Error", message: "It is not a URL", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            }
        default: break
        }
    }
    
    // MARK: - Navigation Delegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SearchMentionSegueIdentifier:
                if let tweetTVC = segue.destination as? TweetTableViewController {
                    if let mention = (sender as? UITableViewCell)?.textLabel?.text {
                        tweetTVC.searchText = mention
                    }
                }
            case Storyboard.ShowImageSegueIdentifier:
                if let ivc = segue.destination as? ImageScrollViewController {
                    let url = (sender as? TweetDetailImageTableViewCell)?.media?.url as? URL
                    let image = (sender as? TweetDetailImageTableViewCell)?.mediaItemImageView?.image
                    
                    ivc.imageSource = (url, image)
                }
            case Storyboard.OpenUrlInWebViewSegueIdentifier:
                if let wvc = segue.destination as? WebViewController {
                    if let url = (sender as? UITableViewCell)?.textLabel?.text {
                        wvc.url = URL(string: url)
                    }
                }
            default:
                break
            }
        }
    }
    
    // MARK: - View controller lifecycle
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
    }
    
}
