//
//  Created by Alin Muntean on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision


class InstaImageProcessor: ImageProcessor {
    
    func processImage(image: Data, completion: @escaping (String?) -> ()) {
        do {
            let model = try VNCoreMLModel(for: Resnet50().model)
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
    
    func processImages(images: [UIImage], completion: @escaping ([IdentifiedImage]) -> ()) {
        let dispatchGroup = DispatchGroup()
        var result = [IdentifiedImage]()
        for image in images {
            let imageData = UIImagePNGRepresentation(image) ?? Data()
            dispatchGroup.enter()
            processImage(image: imageData) { classificationIdentifier in
                let identifiedImage = IdentifiedImage(image: image, actor: classificationIdentifier ?? "")
                result.append(identifiedImage)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(result)
        }
    }
}