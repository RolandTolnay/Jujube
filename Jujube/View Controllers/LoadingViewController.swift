//
//  LoadingViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
  
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var loadingLabel: UIView!

  var instaService: InstagramService!

  override func viewDidLoad() {
    super.viewDidLoad()

    let circleLoader = LiquidLoader(frame: loadingView.frame, effect: .growCircle(#colorLiteral(red: 0.8121558428, green: 0.338460505, blue: 0, alpha: 1), 8, 1.2, #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)))
    view.addSubview(circleLoader)
    
    self.instaService.latestImages(completion: { (analyzedActors) in

      guard let analyzedActors = analyzedActors else {
        print("No analyzed actors found")
        return
      }

      BestPicAlgorithm.shared.setup(withActors: analyzedActors)
      self.dismiss(animated: true, completion: nil)
    })
  }
}
