//
//  PodcastViewController.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 27/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import Cocoa
import CoreData

class PodcastDatasource: NSObject {
    var podcasts: [Podcast] = []
    @IBOutlet weak var tableView: NSTableView!

    var context: NSManagedObjectContext? {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            return context
        }
        return nil
    }

    override init() {
        super.init()

        let notificationCenter = NotificationCenter.default
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            let notificationName = Notification.Name.NSManagedObjectContextDidSave
            notificationCenter.addObserver(self,
                                           selector: #selector(managedObjectContextDidSave(notification:)),
                                           name: notificationName,
                                           object: context)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func managedObjectContextDidSave(notification: Notification) {
        self.getPodcasts()
    }

    func getPodcasts() {
        if let context = self.context {
            let fetchRequest = Podcast.fetchRequest() as NSFetchRequest<Podcast>
            let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [sortByTitle]

            do {
                self.podcasts = try context.fetch(fetchRequest)
            } catch {
                print(error)
            }

            self.tableView.reloadData()
        }
    }

    func podcastsExists(rssURL: String) -> Bool {
        if let context = self.context {
let fetchRequest = Podcast.fetchRequest() as NSFetchRequest<Podcast>
            let predicate = NSPredicate(format: "rssURL == %@", rssURL)
            fetchRequest.predicate = predicate

            do {
                let matchingPodcasts = try context.fetch(fetchRequest)
                return matchingPodcasts.count >= 1
            } catch {
                print(error)
            }
        }
        return false
    }
}

extension PodcastDatasource: NSTableViewDelegate {

}

extension PodcastDatasource: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.podcasts.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "podcastCellIdentifier")
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView

        let podcast = self.podcasts[row]

        if let title = podcast.title {
            cell?.textField?.stringValue = title
        } else {
            cell?.textField?.stringValue = NSLocalizedString("Unknown Title", comment: "Unknown Title")
        }

        return cell
    }
}

class PodcastsViewController: NSViewController {
    @IBOutlet weak var podcastURLTextField: NSTextField!
    @IBOutlet var datasource: PodcastDatasource!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TEST
        self.podcastURLTextField.stringValue = "https://www.npr.org/rss/podcast.php?id=510289"

        self.datasource.getPodcasts()
    }

    @IBAction func addPodcastClicked(_ sender: Any) {
        let urlString = self.podcastURLTextField.stringValue
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data: Data?, _: URLResponse?, error: Error?) in
                guard let data = data else {
                    print(error!)
                    return
                }
                let parser = Parser()
                if let metadata = parser.getPodcastMetadata(data: data) {
                    DispatchQueue.main.async {
                        guard self.datasource.podcastsExists(rssURL: metadata.feedURL) == false else {
                            let alert = NSAlert()
                            alert.messageText = NSLocalizedString("Duplicated Podcast Feed",
                                                                  comment: "Duplicated Podcast Feed")
                            let okTitle = NSLocalizedString("OK", comment: "OK")
                            alert.addButton(withTitle: okTitle)
                            alert.runModal()
                            return
                        }
                        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                            let context = appDelegate.persistentContainer.viewContext
                            let podcast = Podcast(context: context)
                            podcast.imageURL = metadata.imageURL
                            podcast.rssURL = metadata.feedURL
                            podcast.title = metadata.title

                            appDelegate.saveAction(nil)
                        }
                    }
                }
            })
            task.resume()

            self.podcastURLTextField.stringValue = ""
        }
    }
}

extension PodcastsViewController {

}
