//
//  Created by Alin Muntean on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation

protocol ImageProcessor {
    func processImage(image: Data, completion: @escaping (String?) -> ())
}
