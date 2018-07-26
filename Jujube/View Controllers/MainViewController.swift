//
//  ViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit
import SwiftInstagram
import ImagePicker
import Lightbox

class MainViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  let instaService = InstagramService()
  var documentController: UIDocumentInteractionController!

  private var analyzedImages = [AnalyzedImage]()

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
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      guard let vc = storyboard.instantiateViewController(withIdentifier: "loadingVC") as? LoadingViewController else {
        return
      }
      
      vc.instaService = self.instaService
      self.present(vc, animated: true, completion: nil)
    }
  }

  @IBAction func onChoosePhotosTapped(_ sender: Any) {

    var config = Configuration()
    config.doneButtonTitle = "Finish"
    config.noImagesTitle = "Sorry! There are no images here!"
    config.recordLocation = false
    config.allowVideoSelection = false

    let imagePicker = ImagePickerController(configuration: config)
    imagePicker.delegate = self
    imagePicker.imageLimit = 6

    present(imagePicker, animated: true, completion: nil)
  }
  
  func openInstagram(with image: UIImage) {
    
    DispatchQueue.main.async {
      
      //Share To Instagram:
      let instagramURL = URL(string: "instagram://app")
      if UIApplication.shared.canOpenURL(instagramURL!) {
        
        let imageData = UIImageJPEGRepresentation(image, 100)
        let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
        
        do {
          try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
        } catch {
          print(error)
        }
        
        let fileURL = URL(fileURLWithPath: writePath)
        self.documentController = UIDocumentInteractionController(url: fileURL)
        self.documentController.delegate = self
        self.documentController.uti = "com.instagram.exclusivegram"
        self.documentController.presentOpenInMenu(from: self.view.bounds,
                                                  in: self.view,
                                                  animated: true)
      } else {
        print(" Instagram is not installed ")
      }
    }
  }
}

extension MainViewController: UIDocumentInteractionControllerDelegate {
  
}

extension MainViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return analyzedImages.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let cell = collectionView.dequeueReusableCell(with: PhotoCell.self, for: indexPath)
      else { return UICollectionViewCell() }

    let image = analyzedImages[indexPath.row]
    cell.setup(with: image.image, estimatedLikes: image.averageLikes)

    return cell
  }
}

extension MainViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    let image = analyzedImages[indexPath.row].image
    openInstagram(with: image)
  }
}

extension MainViewController: ImagePickerDelegate {

  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePicker.dismiss(animated: true, completion: nil)
  }

  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    guard !images.isEmpty else { return }

    let lightboxImages = images.map {
      return LightboxImage(image: $0)
    }

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    lightbox.dynamicBackground = true
    imagePicker.present(lightbox, animated: true, completion: nil)
  }

  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

    analyzedImages = [AnalyzedImage]()
    images.forEach {
      analyzedImages.append(AnalyzedImage(image: $0, averageLikes: 0))
    }
    collectionView.reloadData()

    imagePicker.dismiss(animated: true, completion: nil)
  }
}
