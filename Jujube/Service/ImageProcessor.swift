//
//  Created by Alin Muntean on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation
import UIKit

protocol ImageProcessor {
    func processImage(image: Data, completion: @escaping (String?) -> ())
    func processImages(images: [UIImage?], completion: @escaping ([IdentifiedImage]) -> ())
}
