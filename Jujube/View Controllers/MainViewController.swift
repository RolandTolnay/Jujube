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

  private enum State {

    case loading
    case populated(images: [AnalyzedImage])
    case empty

    var currentImages: [AnalyzedImage] {
      switch self {
      case .populated(let images):
        return images
      default:
        return []
      }
    }
  }

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

  private let instaService = InstagramService()

  private var state: State = .empty

  override func viewDidLoad() {
    super.viewDidLoad()

    presentLogin()
    setupBestPicAlgorithm()
  }

  // TODO: Remove this after profile analyzer complete
  private func setupBestPicAlgorithm() {

    BestPicAlgorithm.shared.setup(withActors: [
        AnalyzedActor(actor: "lemon", likeCount: 10),
        AnalyzedActor(actor: "ear", likeCount: 5),
        AnalyzedActor(actor: "fountain", likeCount: 3),
        AnalyzedActor(actor: "cliff", likeCount: 32),
        AnalyzedActor(actor: "dam", likeCount: 6)
      ])
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
}

extension MainViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return state.currentImages.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let cell = collectionView.dequeueReusableCell(with: PhotoCell.self, for: indexPath)
      else { return UICollectionViewCell() }

    let image = state.currentImages[indexPath.row]
    cell.setup(with: image.image, estimatedLikes: image.averageLikes)

    return cell
  }
}

extension MainViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    // TODO: Try to upload photo to instagram
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

    imagePicker.dismiss(animated: true, completion: nil)

    state = .loading
    loadingIndicator.startAnimating()
    InstaImageProcessor().processImages(images: images) { identifiedImages in

      print("Identified images: \(identifiedImages)")
      let analyzedImages = BestPicAlgorithm.shared.analyzeImages(identifiedImages)
      self.state = .populated(images: analyzedImages)
      self.loadingIndicator.stopAnimating()
      self.collectionView.reloadData()
    }
  }
}
