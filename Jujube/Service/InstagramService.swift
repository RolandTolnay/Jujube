//
//  InstagramService.swift
//  Jujube
//
//  Created by Balint Dezso on 7/26/18.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation
import SwiftInstagram

class InstagramService {
  
  private let api = Instagram.shared
  private let imageProcessor = InstaImageProcessor()
  private let concurrentQueue = DispatchQueue(label: "cache-concurrent-queue",
                                              qos: .background,
                                              attributes: .concurrent)
  
  
  func login(navigationController: UINavigationController,
             completion: @escaping (_ success: Bool) -> Void) {
  
    api.login(from: navigationController, success: {
      completion(true)
    }, failure: { (error) in
      completion(false)
      print("Could not login with error: \(error.localizedDescription)")
    })
  }
  
  func latestImages(completion: @escaping (_ images: [AnalyzedActor]?) -> Void) {
    
      api.recentMedia(fromUser: "self", count: 20, success: { mediaList in

        let requestsGroup = DispatchGroup()
        var analyzedActors = [AnalyzedActor]()
        
        for media in mediaList {
          
          requestsGroup.enter()
          self.getDataFromUrl(url: media.images.standardResolution.url,
                              completion: { (data) in
                                
                                if let data = data {
                                  
                                  self.imageProcessor.processImage(image: data,
                                                                   completion: { (actor) in
                                    if let actor = actor  {
                                      let analyzedActor = AnalyzedActor(actor: actor,
                                                                        likeCount: media.likes.count)
                                      analyzedActors.append(analyzedActor)
                                      print("Actor: \(actor) for media: \(media.link)")
                                    }
                                    
                                    requestsGroup.leave()
                                  })
                                } else {
                                  requestsGroup.leave()
                                }
          })
        }
        
        requestsGroup.notify(queue: self.concurrentQueue, execute: {
          completion(analyzedActors)
        })
      }, failure: { error in
        print("Could not fetch user media with error: \(error.localizedDescription)")
        completion(nil)
      })
  }
  
  func getDataFromUrl(url: URL,
                      completion: @escaping (_ data: Data?) -> Void) {
    
    URLSession.shared.dataTask(with: url) { (data, _, _) in
      completion(data)
      }.resume()
  }
}
