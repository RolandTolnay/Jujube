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
import SDWebImage

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
  var documentController: UIDocumentInteractionController!

  @IBOutlet weak var accountButton: UIBarButtonItem!
  @IBOutlet weak var chooseNewPhotosButton: UIButton!
  @IBOutlet weak var galleryButton: UIButton!

  private var state: State = .empty

  override func viewDidLoad() {
    super.viewDidLoad()

    presentLogin()
    collectionView.isHidden = true
    chooseNewPhotosButton.isHidden = true
    galleryButton.isHidden = false
  }

  private func presentLogin() {
    
    guard let navigationController = navigationController else {
      return
    }
    
    InstagramService.shared.login(navigationController: navigationController) { (success) in
      
      guard success else {
        return
      }
      
      InstagramService.shared.userIcon(completion: { (url) in
        
        self.getDataFromUrl(url: url, completion: { (data) in

          guard let data = data else {
            return
          }

          guard let image = UIImage(data: data),
            let resizedImage = self.resizeImage(image: image, newWidth: 75.0)
            else { return }

          DispatchQueue.main.sync {

            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
            button.clipsToBounds = true
            button.setImage(resizedImage, for: .normal)
            button.addTarget(self, action: #selector(MainViewController.onAccountIconTapped), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButtonItem
          }
        })
        
      })
      
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      guard let vc = storyboard.instantiateViewController(withIdentifier: "loadingVC") as? LoadingViewController else {
        return
      }
      
      self.present(vc, animated: true, completion: nil)
    }
  }

  @IBAction func didTapAccountIcon(_ sender: UIBarButtonItem) {
    
    onAccountIconTapped()
  }

  @objc private func onAccountIconTapped() {

    if InstagramService.shared.isLoggedIn() {
      performSegue(withIdentifier: "accountSegue",
                   sender: self)
    } else {
      presentLogin()
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
  
  private func openInstagram(with image: UIImage) {
    
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

    let image = state.currentImages[indexPath.row].image
    openInstagram(with: image)
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
      return CGSize.zero
    }
    
    let itemSpacing = flowLayout.minimumInteritemSpacing *
      CGFloat(2 - 1) +
      flowLayout.sectionInset.left +
      flowLayout.sectionInset.right
    
    let width = (collectionView.bounds.width - itemSpacing) / 2.0
    
    return CGSize(width: width, height: 200)
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
      
      self.collectionView.isHidden = false
      self.chooseNewPhotosButton.isHidden = false
      self.galleryButton.isHidden = true
    }
  }
  
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = newWidth
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func getDataFromUrl(url: URL,
                      completion: @escaping (_ data: Data?) -> Void) {
    
    URLSession.shared.dataTask(with: url) { (data, _, _) in
      completion(data)
      }.resume()
  }
}
