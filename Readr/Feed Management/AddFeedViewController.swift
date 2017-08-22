//
//  AddFeedViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedViewController: NSViewController, NSTextFieldDelegate {

    let defaultmessage: String = NSString.localizedStringWithFormat("Enter a URL of a feed you would like Readr to track") as String
    let failureMessage: String = NSString.localizedStringWithFormat("This is not a valid URL") as String
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        urlTextField.delegate = self
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
            label.stringValue = failureMessage as String
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
    
    override func controlTextDidChange(_ obj: Notification) {
        if label.stringValue != defaultmessage {
            label.stringValue = defaultmessage
        }
    }
}
