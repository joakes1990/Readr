//
//  AddFeedViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa
import OklasoftRSS
import OklasoftNetworking

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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(errorFindingFeed(aNotification:)),
                                               name: .feedIdentificationError,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(foundFeeds(aNotification:)),
                                               name: .foundFeedURLs,
                                               object: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
    
    func shake() {
        let animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )]
        
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.duration = 7/100
        
        urlTextField.layer?.add(animation, forKey: nil)
    }
    
    func toggleModal(enable: Bool, message: String?) {
        
    }
    
    @IBAction func addFeed(_ sender: Any) {
        let url: String = ImportFeed.validProtocol(urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ? urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) : "http://\(urlTextField.stringValue)".trimmingCharacters(in: .whitespacesAndNewlines)
        if ImportFeed.validProtocol(urlTextField.stringValue) {
            // Start trying to add url
            print("Good to go")
        } else {
            label.stringValue = failureMessage as String
            shake()
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if label.stringValue != defaultmessage {
            label.stringValue = defaultmessage
        }
    }
    
    @objc func errorFindingFeed(aNotification: Notification) {
        guard let userinfo: [AnyHashable : Any] = aNotification.userInfo,
        let error: Error = userinfo[errorInfoKey] as? Error ?? nil else {
            urlTextField.stringValue = NSLocalizedString("Oops, We didn't find your news feed. ¯\\_(ツ)_/¯", comment: "Oops, We didn't find your news feed. ¯\\_(ツ)_/¯")
            shake()
            return
        }
        urlTextField.stringValue = error.localizedDescription
        shake()
    }
    
    @objc func foundFeeds(aNotification: Notification) {
        guard let userinfo: [AnyHashable : Any] = aNotification.userInfo,
            let url: String = userinfo.keys.first as? String,
            let links: [Link] = userinfo[url] as? [Link] ?? nil else {
                toggleModal(enable: true, message: NSLocalizedString("No feeds where found on that site.", comment: "No feed where found for this site"))
                return
        }
        
    }
}
