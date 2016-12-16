//
//  TweetDetailImageTableViewCell.swift
//  Smashtag
//
//  Created by 李天培 on 2016/11/27.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailImageTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaItemImageView: UIImageView!
    
    private var lastURL: URL?
    
    var media: Twitter.MediaItem? {
        didSet {
            if let url = media?.url as? URL {
                lastURL = url
                DispatchQueue.global(qos: .userInteractive).async { [weak weakSelf = self] in
                    if let imageData = NSData(contentsOf: url) {
                        if url == weakSelf?.lastURL {
                            DispatchQueue.main.async {
                                weakSelf?.mediaItemImageView.image = UIImage(data: imageData as Data)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
