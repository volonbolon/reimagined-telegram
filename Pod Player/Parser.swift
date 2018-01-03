//
//  Parser.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 28/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import Foundation

struct PodcastMetadata {
    let title: String
    let imageURL: String
    let feedURL: String

    init(title: String, imageURL: String, feedURL: String) {
        self.title = title
        self.imageURL = imageURL
        self.feedURL = feedURL
    }
}

struct Parser {
    func getPodcastMetadata(data: Data) -> PodcastMetadata? {
        let xml = SWXMLHash.parse(data)
        let channel = xml["rss"]["channel"]
        guard let title = channel["title"].element?.text else {
            return nil
        }
        guard let imageURL = channel["itunes:image"].element?.attribute(by: "href")?.text else {
            return nil
        }
        guard let feedURL = channel["itunes:new-feed-url"].element?.text else {
            return nil
        }
        let metadata = PodcastMetadata(title: title, imageURL: imageURL, feedURL: feedURL)
        return metadata
    }

    func getEpisodes(data: Data) -> [Episode] {
        var episodes: [Episode] = []
        let xml = SWXMLHash.parse(data)
        let channel = xml["rss"]["channel"]
        for item in channel["item"].all {
            var payload: [String: String] = [:]
            if let title = item["title"].element?.text {
                payload[Episode.titleKey] = title
            }

            if let htmlDesc = item["description"].element?.text {
                payload[Episode.descriptionKey] = htmlDesc
            }

            if let link = item["enclosure"].element?.attribute(by: "url")?.text {
                payload[Episode.audioURLKey] = link
            } else if let link = item["link"].element?.text {
                payload[Episode.audioURLKey] = link
            }

            if let pubDate = item["pubDate"].element?.text {
                payload[Episode.publicationDateKey] = pubDate
            }

            let episode = Episode(payload: payload)
            episodes.append(episode)
        }

        return episodes
    }
}
