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
  
    static let shared = InstagramService()
  private let api = Instagram.shared
  private let imageProcessor = InstaImageProcessor()
  private let concurrentQueue = DispatchQueue(label: "cache-concurrent-queue",
                                              qos: .background,
                                              attributes: .concurrent)
  
  func userIcon(completion: @escaping (_ profileURL: URL) -> Void) {
    api.user("self", success: { (user) in
      completion(user.profilePicture)
    }, failure: nil)
  }
  
  func isLoggedIn() -> Bool {
    
    return api.isAuthenticated
  }
  
  func login(navigationController: UINavigationController,
             completion: @escaping (_ success: Bool) -> Void) {
  
    api.login(from: navigationController, success: {
      completion(true)
    }, failure: { (error) in
      completion(false)
      print("Could not login with error: \(error.localizedDescription)")
    })
  }
  
  func logout() {
    api.logout()
  }
  
  func latestImages(completion: @escaping (_ images: [AnalyzedActor]?) -> Void) {
    
      api.recentMedia(fromUser: "self", count: 20, success: { mediaList in

        let requestsGroup = DispatchGroup()
        var analyzedActors = [AnalyzedActor]()
        
        self.concurrentQueue.async {
          
        
        for media in mediaList {
          
            requestsGroup.enter()
            self.getDataFromUrl(url: media.images.standardResolution.url,
                                completion: { (data) in
                                  
                                  if let data = data {
                                    debugPrint("Starting for: " + media.link.absoluteString)
                                    self.imageProcessor.processImage(image: data,
                                                                     completion: { actors in
                                                                        debugPrint("Finished for: " + media.link.absoluteString)
                                                                      
                                                                      for actor in actors {
                                                                        let analyzedActor = AnalyzedActor(actor: actor,
                                                                                                          likeCount: media.likes.count)
                                                                        analyzedActors.append(analyzedActor)
                                                                      }
                                                                      
                                                                      print("Actor: \(actors) for media: \(media.link)")
                                                                      requestsGroup.leave()
                                    })
                                  } else {
                                    requestsGroup.leave()
                                  }
            })
          }
          
          
          requestsGroup.notify(queue: DispatchQueue.main, execute: {
            completion(analyzedActors)
          })
        }
        
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
