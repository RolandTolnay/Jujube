//
//  BestPicAlgorithm.swift
//  Jujube
//
//  Created by Alin Stafie-Ghilase on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation

struct ActorAverage {
    let actor: String
    var average: Float
}

class BestPicAlgorithm {
    
    static let shared = BestPicAlgorithm()
    private var averages = [ActorAverage]()
    
    func getAnalysisResults() -> [ActorAverage] {
        
        return averages
    }
    
    func setup(withActors actors: [AnalyzedActor]) {
        
        actors.forEach { analyzedActor in
            if let index = averages.index(where: {
                return $0.actor == analyzedActor.actor
            }) {
                var actorAverage = averages[index]
                actorAverage.average = (actorAverage.average + Float(analyzedActor.likeCount))/2
                averages[index] = actorAverage
            } else {
                averages.append(ActorAverage(actor: analyzedActor.actor, average: Float(analyzedActor.likeCount)))
            }
        }
        averages.sort { (firstActor, secondActor) -> Bool in
            return firstActor.average > secondActor.average
        }
    }
    
    func analyzeImages(_ images: [IdentifiedImage]) -> [AnalyzedImage] {
        
        var analyzedImages = [AnalyzedImage]()
        images.forEach { image in
            let actorAverage = averages.first(where: {
                return image.actor.contains($0.actor)
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
