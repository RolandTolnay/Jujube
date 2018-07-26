//
//  ViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  let instaService = InstagramService()

  private var analyzedImages: [AnalyzedImage] = [
    AnalyzedImage(image: UIImage(), averageLikes: 0.0)
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    presentLogin()
  }
  
  private func presentLogin() {
    
    guard let navigationController = navigationController else {
      return
    }
    
    instaService.login(navigationController: navigationController) { (success) in
      
      guard success else {
        return
      }
      
      self.instaService.latestImages(completion: { (data) in
        print("adsad")
      })
    }
  }


  @IBAction func onChoosePhotosTapped(_ sender: Any) {

    
  }
}

extension MainViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return 6
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let cell = collectionView.dequeueReusableCell(with: PhotoCell.self, for: indexPath)
      else { return UICollectionViewCell() }

    let image = analyzedImages[0]
    cell.setup(with: image.image, estimatedLikes: image.averageLikes)

    return cell
  }
}

extension MainViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    // TODO: Try to upload photo to instagram
  }
}
