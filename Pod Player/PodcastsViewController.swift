//
//  PodcastViewController.swift
//  Pod Player
//
//  Created by Ariel Rodriguez on 27/12/2017.
//  Copyright © 2017 Ariel Rodriguez. All rights reserved.
//

import Cocoa

class PodcastsViewController: NSViewController {
    @IBOutlet weak var podcastURLTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func addPodcastClicked(_ sender: Any) {
        let urlString = self.podcastURLTextField.stringValue
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                guard let data = data else {
                    print(error!)
                    return
                }
                print(data)
            })
            task.resume()
        }
    }
}
