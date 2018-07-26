//
//  BestPicAlgorithm.swift
//  Jujube
//
//  Created by Alin Stafie-Ghilase on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation

private struct ActorAverage {
    let actor: String
    var average: Float
}

class BestPicAlgorithm {
    
    static let shared = BestPicAlgorithm()
    private var averages = [ActorAverage]()
    
    func setup(withActors actors: [AnalyzedActor]) {
        
        actors.forEach { analyzedActor in
            if var actorAverage = averages.first(where: {
                return $0.actor == analyzedActor.actor
            }) {
                actorAverage.average = (actorAverage.average + Float(analyzedActor.likeCount))/2

            } else {
                averages.append(ActorAverage(actor: analyzedActor.actor, average: Float(analyzedActor.likeCount)))
            }
        }
    }
    
    func analyzeImages(_ images: [IdentifiedImage]) -> [AnalyzedImage] {
        
        var analyzedImages = [AnalyzedImage]()
        images.forEach { image in
            let actorAverage = averages.first(where: {
                return $0.actor == image.actor
            })
            analyzedImages.append(AnalyzedImage(image: image.image, averageLikes: actorAverage?.average))
        }
        return analyzedImages.sorted(by: { (image1, image2) -> Bool in
            if let firstImageAverage = image1.averageLikes {
                if let secondImageAverage = image2.averageLikes {
                    return firstImageAverage > secondImageAverage
                } else {
                    return true
                }
            } else {
                return image2.averageLikes == nil
            }
        })
    }
}
