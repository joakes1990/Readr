//
//  AddFeedViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedViewController: NSViewController {

    static let defaultmessage = NSString.localizedStringWithFormat("Enter a URL of a feed you would like Readr to track")
    @IBOutlet weak var urlTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        urlTextField.wantsLayer = true
        if let clipBoardURL: String = ImportFeed.urlFromClipboard() {
            urlTextField.stringValue = clipBoardURL
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func addFeed(_ sender: Any) {
        if ImportFeed.validProtocol(urlTextField.stringValue) {
            // Start trying to add url
        } else {
            let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
            animation.values = [
                NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
                NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )]
            
            animation.autoreverses = true
            animation.repeatCount = 2
            animation.duration = 7/100
            
            urlTextField.layer?.add(animation, forKey: nil)
        }
    }
}
