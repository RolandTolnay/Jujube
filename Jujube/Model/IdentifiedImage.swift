//
//  IdentifiedImage.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

struct IdentifiedImage: CustomStringConvertible {

  let image: UIImage
  let actor: String

  var description: String {

    return "Actor: \(actor)"
  }
}
