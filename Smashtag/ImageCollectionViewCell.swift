//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/10.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
}
