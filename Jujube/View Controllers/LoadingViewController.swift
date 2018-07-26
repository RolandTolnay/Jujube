//
//  LoadingViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()

      InstagramService.shared.latestImages(completion: { (analyzedActors) in
        guard let analyzedActors = analyzedActors else {
          return
        }
        
        BestPicAlgorithm.shared.setup(withActors: analyzedActors)
        self.dismiss(animated: true, completion: nil)
      })
  }

}
