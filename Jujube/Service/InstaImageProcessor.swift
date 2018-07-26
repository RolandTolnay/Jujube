//
//  Created by Alin Muntean on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision
import SwiftyJSON


class InstaImageProcessor: ImageProcessor {
    
    private let session = URLSession.shared
    private let googleAPIKey = "AIzaSyCGQleyq_4KkUCZ2qI4w7bGLcjmJ2GVpm4"
    private var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    func processImage(image: Data, completion: @escaping (String?) -> ()) {
        guard let uiImage = UIImage(data: image) else { return completion(nil) }
        let binaryImageData = base64EncodeImage(uiImage)
        createRequest(with: binaryImageData, completion: completion)
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
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String, completion: @escaping (String?) -> ()) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 3
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            completion(nil)
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async {
            self.runRequestOnBackgroundThread(request, completion: completion)
        }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest, completion: @escaping (String?) -> ()) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                completion(nil)
                return
            }
            
            self.analyzeResults(data, completion: completion)
        }
        
        task.resume()
    }
    
    func analyzeResults(_ dataToParse: Data, completion: @escaping (String?) -> ()) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(dataToParse)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                debugPrint("Error code \(errorObj["code"]): \(errorObj["message"])")
                completion(nil)
            } else {
                // Parse the response
                let responses: JSON = json["responses"][0]
                
                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels = labelAnnotations.count
                var labels = [String]()
                if numLabels > 0 {
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    debugPrint(labels)
                    completion(labels.first)
                } else {
                    debugPrint("No labels found")
                    completion(nil)
                }
            }
        })
    }
}
