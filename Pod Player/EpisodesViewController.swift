//
//  EpisodesViewController.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 29/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import Cocoa
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}

protocol EpisodesDatasourceDelegate: class {
    func episodeSelected(episode: Episode)
}

class EpisodesTableViewDatasource: NSObject {
    var episodes: [Episode] = []
    weak var delegate: EpisodesDatasourceDelegate?
    @IBOutlet weak var tableView: NSTableView!
}

extension EpisodesTableViewDatasource: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.tableView.selectedRow
        if selectedRow >= 0 && selectedRow < self.episodes.count {
            if let delegate = self.delegate {
                let episode = self.episodes[selectedRow]
                delegate.episodeSelected(episode: episode)
            }
        }
    }
}

extension EpisodesTableViewDatasource: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.episodes.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "episodeCellIdentifier")
        if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
            let episode = self.episodes[row]
            cell.textField?.stringValue = episode.title
            return cell
        }
        return nil
    }
}

class EpisodesViewController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    fileprivate var podcast: Podcast?

    var player: AVPlayer?

    var context: NSManagedObjectContext? {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            return context
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let datasource = self.tableView.dataSource as? EpisodesTableViewDatasource {
            datasource.delegate = self
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePodcastSelected(notification:)),
                                               name: Constants.Notifications.PodcastSelected,
                                               object: nil)
    }

    @IBAction func pauseButtonClicked(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        if player.isPlaying {
            player.pause()
            self.pauseButton.title = NSLocalizedString("Play", comment: "Play")
        } else {
            player.play()
            self.pauseButton.title = NSLocalizedString("Pause", comment: "Pause")
        }

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
            self.getEpisodes()
        } else {
            self.titleLabel.stringValue = ""
            self.imageView.image = nil
        }
    }
}

extension EpisodesViewController {
    func getEpisodes() {
        if let urlString = self.podcast?.rssURL, let url = URL(string: urlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data: Data?, _: URLResponse?, error: Error?) in
                guard let data = data else {
                    print(error!)
                    return
                }
                let parser = Parser()
                let episodes = parser.getEpisodes(data: data)
                DispatchQueue.main.async {
                    if let datasource = self.tableView.dataSource as? EpisodesTableViewDatasource {
                        datasource.episodes = episodes
                        self.tableView.reloadData()
                    }
                }
            })
            task.resume()
        }
    }
}

extension EpisodesViewController: EpisodesDatasourceDelegate {
    func episodeSelected(episode: Episode) {
        if let url = URL(string: episode.audioURL) {
            self.player?.pause()
            self.player = nil

            self.player = AVPlayer(url: url)
            self.player?.play()

            self.pauseButton.title = NSLocalizedString("Pause", comment: "Pause")
            self.pauseButton.isHidden = false
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
