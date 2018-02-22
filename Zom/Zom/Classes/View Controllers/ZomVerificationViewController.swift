//
//  ZomVerificationViewController.swift
//  Zom
//
//  Created by Benjamin Erhart on 22.02.18.
//

import UIKit

class ZomVerificationViewController: UIViewController {

    @objc public var buddy: OTRBuddy?

    @IBOutlet weak var infoLb: UILabel!
    @IBOutlet weak var codeLb: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var matchBt: UIButton!
    @IBOutlet weak var noMatchBt: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleView = OTRTitleSubtitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleView.titleLabel.text = NSLocalizedString("Compare Codes",
                                                      comment: "Title for code verification scene")
        titleView.subtitleLabel.text = buddy?.username
        navigationItem.titleView = titleView

        infoLb.text = NSLocalizedString(
            "Make sure this code matches your friend's latest Zom code on their phone.",
            comment: "Description for code verification scene")

        if let buddy = buddy, let db = OTRDatabaseManager.sharedInstance().readOnlyDatabaseConnection {
            db.asyncRead() { (transaction: YapDatabaseReadTransaction) in
                if let account = buddy.account(with: transaction) {
                    let allFingerprints = OTRProtocolManager.encryptionManager.otrKit.fingerprints(
                        forUsername: buddy.username, accountName: account.username,
                        protocol: account.protocolTypeString())

                    if let fingerprint = allFingerprints.first {
                        // TODO: This is not working, yet.
                        // Also, it seems, OMEMO fingerprints have to be fetched seperately.
                        
                        self.setFingerprint((fingerprint.fingerprint as NSData).humanReadableFingerprint())
                    }
                    else {
                        self.setFingerprint(nil)
                    }
                }
                else {
                    self.setFingerprint(nil)
                }
            }
        }
        else {
            setFingerprint(nil)
        }

        avatarImg.image = buddy?.avatarImage

        noMatchBt.titleLabel?.text = NSLocalizedString("Codes don't match",
                                                       comment: "Verification scene button text")
    }

    @IBAction func match() {
    }
    
    @IBAction func noMatch() {
    }

    private func setFingerprint(_ text: String?) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.alignment = .center

        let string = text ?? NSLocalizedString(
                "CODE ERROR", comment: "Error message instead of code which could not be read")

        DispatchQueue.main.async {
            self.codeLb.attributedText = NSAttributedString(
                string: string, attributes: [.kern: 3, .paragraphStyle: style])
        }
    }
}
