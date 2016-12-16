//
//  TweetDetailTweetTableViewCell.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/12.
//  Copyright © 2016年 lee. All rights reserved.
//


import UIKit
import Twitter

class TweetDetailTweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // reset any existing tweet information
        tweetScreenNameLabel?.attributedText = nil
        tweetTextLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet {
            // set tweet attribute text
            let tweetAttributeText = NSMutableAttributedString(string: tweet.text)
            
            
            for hashtag in tweet.hashtags {
                tweetAttributeText.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: hashtag.nsrange)
            }
            for userMetion in tweet.userMentions {
                tweetAttributeText.addAttributes([NSForegroundColorAttributeName: UIColor.gray], range: userMetion.nsrange)
            }
            for url in tweet.urls {
                tweetAttributeText.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: url.nsrange)
            }
            
            tweetTextLabel.attributedText = tweetAttributeText
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                lastURL = profileImageURL
                DispatchQueue.global(qos: .userInteractive).async { [weak weakSelf = self] in
                    if let imageData = NSData(contentsOf: profileImageURL), profileImageURL == weakSelf?.lastURL {
                        DispatchQueue.main.async {
                            weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData as Data)
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if Date().timeIntervalSince(tweet.created) > 24 * 60 * 60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }
    }
    
    private var lastURL: URL?
    
}
