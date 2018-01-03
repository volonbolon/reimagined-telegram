//
//  EpisodesViewController.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 29/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import Cocoa

class EpisodesTableViewDatasource: NSObject {

}

extension EpisodesTableViewDatasource: NSTableViewDelegate {

}

extension EpisodesTableViewDatasource: NSTableViewDataSource {

}

class EpisodesViewController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    fileprivate var podcast: Podcast?

    var context: NSManagedObjectContext? {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            return context
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePodcastSelected(notification:)),
                                               name: Constants.Notifications.PodcastSelected,
                                               object: nil)
    }

    @IBAction func pauseButtonClicked(_ sender: Any) {
    }

    @IBAction func deleteButtonClicked(_ sender: Any) {
        guard let podcast = self.podcast else {
            return
        }
        if let context = self.context {
            context.delete(podcast)
            self.podcast = nil
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.saveAction(nil)
            }
            self.updateView()
        }
    }

    func updateView() {
        if let podcast = self.podcast {
            if let title = podcast.title {
                self.titleLabel.stringValue = title
            }
            if let imageURLString = podcast.imageURL, let url = URL(string: imageURLString) {
                let image = NSImage(byReferencing: url)
                self.imageView.image = image
            }
            self.pauseButton.isHidden = true
        } else {
            self.titleLabel.stringValue = ""
            self.imageView.image = nil
        }
    }
}

extension EpisodesViewController {
    @objc func handlePodcastSelected(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let objectId = userInfo[Constants.NotificationUserInfoKeys.PodcastSelectedObjectId] as? NSManagedObjectID {
            if let context = self.context {
                if let podcast = context.object(with: objectId) as? Podcast {
                    self.podcast = podcast
                    self.updateView()
                }
            }
        }
    }
}
