//
//  WebViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/5.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    private var backItem: UIBarButtonItem!
    private var forwardItem: UIBarButtonItem!
    
    var url: URL! { didSet { loadURL() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
        webView.delegate = self
        backItem = UIBarButtonItem(title: "＜", style: .plain, target: webView, action: #selector(webView.goBack))
        forwardItem = UIBarButtonItem(title: "＞", style: .plain, target: webView, action: #selector(webView.goForward))
        toolbarItems = [backItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),forwardItem]
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        backItem?.isEnabled = webView.canGoBack
        forwardItem?.isEnabled = webView.canGoForward
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        backItem?.isEnabled = webView.canGoBack
        forwardItem?.isEnabled = webView.canGoForward

    }
    
    private func loadURL() {
        webView?.loadRequest(URLRequest(url: url))
    }
}
