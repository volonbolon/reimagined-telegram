//
//  Constants.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 01/01/2018.
//  Copyright © 2018 Ariel Rodriguez. All rights reserved.
//

import Foundation

struct Constants {
    struct Notifications {
        static let PodcastSelected = Notification.Name(rawValue: "podcastSelected")
    }
    struct NotificationUserInfoKeys {
        static let PodcastSelectedObjectId = "Constants.NotificationUserInfoKeys.podcastSelectedObjectId"
    }
}
