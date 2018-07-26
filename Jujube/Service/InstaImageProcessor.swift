//
//  Created by Alin Muntean on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import CoreML
import Vision


class InstaImageProcessor: ImageProcessor {
    
    func processImage(image: Data, completion: @escaping (String?) -> ()) {
        do {
            let model = try VNCoreMLModel(for: MobileNet().model)
            let request = VNCoreMLRequest(model: model) { request, error in
                DispatchQueue.main.async {
                    guard let classification = request.results?.first as? VNClassificationObservation else { return completion(nil) }
                    completion(classification.identifier)
                }
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(data: image)
                do {
                    try handler.perform([request])
                } catch {
                    debugPrint(error)
                }
            }
        } catch {
            debugPrint(error)
        }
    }
}
