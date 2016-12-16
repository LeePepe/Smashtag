//
//  TweetImageCollectionViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/8.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "Tweet Media Image"

class TweetImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Model
    
    var mediaWithTweet = Array<(media: Twitter.MediaItem, tweet: Twitter.Tweet)>() {
        didSet {
            for tuple in mediaWithTweet {
                let url = tuple.media.url as URL
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    if let data = NSData(contentsOf: url) {
                        self?.cache.setObject(data, forKey: url as NSURL)
                    }
                }
            }
        }
    }
    
    var cache = NSCache<NSURL, NSData>()
    
    private struct Storyboard {
        static let MaxCellPerRow = 6
        static let MinCellPerRow = 1
        static let ShowTweetSegueIdentifier = "Show Tweet Info"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(TweetImageCollectionViewController.zoomCellSize(gesture:))))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowTweetSegueIdentifier:
                if let tweetDetailTVC = segue.destination.content as? TweetDetailTableViewController {
                    // Get the Tweet info from cell
                    if let cell = sender as? ImageCollectionViewCell {
                        if let index = collectionView?.indexPath(for: cell) {
                            tweetDetailTVC.tweet = mediaWithTweet[index.row].tweet
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return mediaWithTweet.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        if let ivc = cell as? ImageCollectionViewCell {
            // get image data from cache or download from url
            if let imageData = cache.object(forKey: mediaWithTweet[indexPath.row].media.url) as? Data {
                ivc.image = UIImage(data: imageData)
            } else {
                let url = mediaWithTweet[indexPath.row].media.url
                let oldURL = url
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    if let data = try? Data(contentsOf: url as URL) {
//                        if url == oldURL {
                            DispatchQueue.main.async {
                                if self?.cache.object(forKey: url) == nil {
                                    self?.cache.setObject(data as NSData, forKey: url)
                                }
                                ivc.image = UIImage(data: data)
                            }
//                        }
                    }
                }
                
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private var cellCountOfPerRow = 4 {
        didSet {
            collectionView?.setCollectionViewLayout((collectionView?.collectionViewLayout)!, animated: true)
        }
    }
    
    @objc private func zoomCellSize(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            if gesture.scale > 1.5 {
                gesture.scale = 1.0
                cellCountOfPerRow = min(Storyboard.MaxCellPerRow, cellCountOfPerRow + 1)
            } else if gesture.scale < 0.7 {
                gesture.scale = 1.0
                cellCountOfPerRow = max(Storyboard.MinCellPerRow, cellCountOfPerRow - 1)
            }
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - CGFloat(cellCountOfPerRow)) / CGFloat(cellCountOfPerRow),
                      height: (collectionView.bounds.size.width - CGFloat(cellCountOfPerRow)) / CGFloat(cellCountOfPerRow))
    }
    
}
