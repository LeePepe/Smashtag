//
//  ImageScrollViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/11/29.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.01
            scrollView.maximumZoomScale = 2.0
        }
    }
    
    private var imageView = UIImageView()
    
    var imageSource: (URL?, UIImage?) {
        didSet {
            if let data = imageSource.1 {
                image = data
            } else if let url = imageSource.0 {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak self] in
                            if url == self?.imageSource.0 {
                                self?.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var image: UIImage? {
        didSet {
            if image != nil {
                imageView.image = image
                imageView.sizeToFit()
                autoZoom()
            }
        }
    }
    
    private func autoZoom() {
        if scrollView != nil && image != nil {
            scrollView.contentSize = imageView.bounds.size
            scrollView.minimumZoomScale = 0.01
            scrollView.zoomScale =  max((scrollView.bounds.size.height / imageView.image!.size.height),
                                        (scrollView.bounds.size.width / imageView.image!.size.width))

            scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.size.width) / 2,
                                       y: (imageView.frame.size.height - scrollView.frame.size.height) / 2)
            scrollView.zoom(to: imageView.bounds, animated: true)
            scrollView.minimumZoomScale = scrollView.zoomScale
            print("imageView.frame.size \(imageView.frame.size) image.size \(imageView.image?.size) imageView.bounds.size \(imageView.bounds.size)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        autoZoom()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    
    
}
