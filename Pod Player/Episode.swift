//
//  Episode.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 03/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

struct Episode {
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }

    static let titleKey = "title"
    static let publicationDateKey = "pubDate"
    static let descriptionKey = "description"
    static let audioURLKey = "audioURL"

    let title: String
    let publicationDate: Date
    let htmlDescription: String
    let audioURL: String

    init(payload: [String: String]) {
        self.title = payload[Episode.titleKey]!
        let pubDateString = payload[Episode.publicationDateKey]!
        if let pubDate = Episode.dateFormatter.date(from: pubDateString) {
            self.publicationDate = pubDate
        } else {
            self.publicationDate = Date()
        }
        self.htmlDescription = payload[Episode.descriptionKey]!
        self.audioURL = payload[Episode.audioURLKey]!
    }
}
