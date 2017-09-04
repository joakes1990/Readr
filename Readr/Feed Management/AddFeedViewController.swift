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
import OklasoftError

class AddFeedViewController: NSViewController, NSTextFieldDelegate, ImportProtocol {
    
    let defaultmessage: String = NSString.localizedStringWithFormat("Enter a URL of a feed you would like Readr to track") as String
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
        urlTextField.wantsLayer = true
        if let clipBoardURL: String = ImportFeed.shared.urlFromClipboard() {
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
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
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
        if enable {
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(self)
        } else {
            progressIndicator.isHidden = true
            progressIndicator.stopAnimation(self)
        }
        label.stringValue = message ?? "Readr"
    }
    
    
    @IBAction func addFeed(_ sender: Any) {
        let url: String = ImportFeed.shared.validProtocol(urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ? urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) : "http://\(urlTextField.stringValue)".trimmingCharacters(in: .whitespacesAndNewlines)
        if ImportFeed.shared.validProtocol(url) {
            let message: String = NSLocalizedString("Looking for feeds 👀", comment: "Looking for feeds 👀")
            toggleModal(enable: true, message: message)
            ImportFeed.shared.identifyFeed(at: url)
        } else {
            toggleModal(enable: false, message: invalidURLError.localizedDescription)
            shake()
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if label.stringValue != defaultmessage {
            toggleModal(enable: false, message: defaultmessage)
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
