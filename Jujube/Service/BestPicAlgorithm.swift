//
//  BestPicAlgorithm.swift
//  Jujube
//
//  Created by Alin Stafie-Ghilase on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation

fileprivate struct ActorAverage {
    let actor: String
    var average: Float
}

class BestPicAlgorithm {
    
    static let shared = BestPicAlgorithm()
    private var averages = [ActorAverage]()
    
    func setup(withActors actors: [AnalyzedActor]) {
        
        actors.forEach { analyzedActor in
            if !averages.contains(where: {
                if $0.actor == analyzedActor.actor {
                    $0.average = ($0.average + Float(analyzedActor.likeCount))/2
                    return true
                }
                return false
            }) {
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
    }
}
