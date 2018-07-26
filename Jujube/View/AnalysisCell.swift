//
//  AnalysisCell.swift
//  Jujube
//
//  Created by Alin Stafie-Ghilase on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class AnalysisCell: UITableViewCell {
    
    @IBOutlet weak var actor: UILabel!
    @IBOutlet weak var average: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    func setup(with actorAverage: ActorAverage, forMaxLikes max: Float) {
        
        actor.text = actorAverage.actor
        average.text = String(format: "%.f", actorAverage.average)
        average.textColor = .orange
        if actorAverage.average > (2*max)/3 {
            average.textColor = #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
        } else if actorAverage.average < max/3 {
            average.textColor = #colorLiteral(red: 0.5461038947, green: 0.2558558583, blue: 0.703636229, alpha: 1)
        } else {
            average.textColor = #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
        }
        downloadImageForActor(actorAverage.actor)
    }
    
    private func downloadImageForActor(_ actor: String) {
        
        guard let escapedActor = actor.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "https://www.googleapis.com/customsearch/v1?q=\(escapedActor)&searchType=image&key=AIzaSyAyW6X5Bh-JHxkYyQmcwS6URlsR-dU24xc&cx=017426432613049717893:d1u8bllqhjo") else { return }
        let urlSession = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if let data = data, response.statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            let items = json["items"] as! [[String:Any]]
                            let index = Int(arc4random_uniform(UInt32(items.count)))
                            let link = items[index]["link"] as! String
                            print(link)
                            self.backgroundImage.sd_setImage(with: URL(string: link), placeholderImage: UIImage())
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}
