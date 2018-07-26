//
//  ViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit
import SwiftInstagram

class MainViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    presentLogin()
  }
  
  private func presentLogin() {
    
    let api = Instagram.shared
    
    guard let navigationController = navigationController else {
      return
    }
    
    api.login(from: navigationController, success: {
      api.recentMedia(fromUser: "self", count: 20, success: { mediaList in
        
        print(mediaList)
        
      }, failure: { error in
        print("Could not fetch user media with error: \(error.localizedDescription)")
      })
    }, failure: { error in
      print("Could not login with error: \(error.localizedDescription)")
    })
  }
}
