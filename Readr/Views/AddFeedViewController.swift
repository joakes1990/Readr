//
//  AddFeedViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedViewController: NSViewController, NSTextFieldDelegate, FeedImportProtocol {
    
    
    let defaultmessage: String = NSString.localizedStringWithFormat("Enter a URL of a feed you would like Readr to track") as String
    static let segue: String = "selectFeeds"
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    let feedImporter: ImportFeed = ImportFeed()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedImporter.delegateView = self
        urlTextField.delegate = self
        urlTextField.wantsLayer = true
        if let clipBoardURL: String = ImportFeed.urlFromClipboard() {
            urlTextField.stringValue = clipBoardURL
        }
    }
    
    override func viewDidDisappear() {
        feedImporter.delegateView = nil
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
        let url: String = urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if ImportFeed.validProtocol(url) {
            let message: String = NSLocalizedString("Looking for feeds 👀", comment: "Looking for feeds 👀")
            toggleModal(enable: true, message: message)
            feedImporter.identifyFeed(at: url)
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
    
    func foundFeed(feed: Feed?) {
        let foundMessage: String = NSLocalizedString("New feed added!", comment: "New feed added!")
        let dismissDate: DispatchTime = DispatchTime(uptimeNanoseconds: DispatchTime.now().rawValue + 3000000000)
        unowned let unownedSelf: AddFeedViewController = self
        toggleModal(enable: false, message: foundMessage)
        FeedImportDelegate.shared.foundFeed(feed: feed)
        DispatchQueue.main.asyncAfter(deadline: dismissDate) {
            unownedSelf.dismiss(unownedSelf)
        }
    }
    
    func foundLinks(links: [Link]?) {
        performSegue(withIdentifier: .selectFeedsSegue, sender: self)
    }
    
    func returned(error: oklasoftError) {
        let errorMessage: String = NSLocalizedString("Opps, an error occured trying to load this feed", comment: "Opps, an error occured trying to load this feed")
        //TODO: log error
        toggleModal(enable: false, message: errorMessage)
    }
    
}


