//
//  PhotoCell.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var likesLabel: UILabel!

  func setup(with image: UIImage,
             estimatedLikes: Float?) {

    imageView.image = image
    likesLabel.text = "Estimated likes: \(estimatedLikes ?? 0)"
  }
}
