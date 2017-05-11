//
//  Utils.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import UIKit


// This class contains auxiliary functions that can be invoked from any point of the app
// (all of them are class functions)

class Utils {
    
    // Alias for trailing closures, these functions will always be executed in the main queue.
    // They receive an optional so that they can manage nil in case it comes from a failed operation.
    typealias imageClosure = (UIImage?) -> ()
    typealias dataClosure = (Data?) -> ()
    
    
    // Downloads a remote image in background.
    // If the operation succeeded, passes the corresponding UIImage to the closure. If not, passes nil.
    // 
    // Params:
    // 
    // - fromUrl: string with the URL of the remote image
    // - mustResize: true if the image should be resized to fit the screen size, or false if it must keep its original size
    // - activityIndicator: if not nil, enables the passed UIActivityIndicatorView during the asynchronous operation
    // - completion: trailing closure that receives an UIImage?, will run in the main queue
    
    class func asyncDownloadImage(fromUrl urlString: String, mustResize: Bool, activityIndicator: UIActivityIndicatorView?, completion: @escaping imageClosure) {
        
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        // Download image and build UImage (in background)
        
        //DispatchQueue.global(qos: .userInitiated).async {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1) ) {     // Give 1 sec. for the activity indicator to show
            
            var finalImage: UIImage?
            
            do {
                let imageUrl = URL(string: urlString)
                
                if imageUrl != nil {
                    
                    let data = try Data(contentsOf: imageUrl!)
                    let originalImage = UIImage(data: data)!
                    
                    if mustResize {
                        finalImage = Utils.resizeImage(originalImage, toSize: screenSize() )
                    }
                    else {
                        finalImage = originalImage
                    }
                    
                }
                else
                {
                    finalImage = nil
                }
            }
            catch {
                finalImage = nil
            }
            
            // Hide the activity indicator and pass the UIImage to the closure (in the main queue)
            DispatchQueue.main.async {
                
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                
                completion(finalImage)
            }
        }
        
    }
    
    
    // Downloads the data of a remote url in background.
    // If the operation succeeded, passes the corresponding Data to the closure. If not, passes nil.
    //
    // Params:
    //
    // - fromUrl: string with the remote URL
    // - activityIndicator: if not nil, enables the passed UIActivityIndicatorView during the asynchronous operation
    // - completion: trailing closure that receives a Data?, will run in the main queue
    
    class func asyncDownloadData(fromUrl urlString: String, activityIndicator: UIActivityIndicatorView?, completion: @escaping dataClosure) {
        
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        // Download data and build the Data object (in background)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1) ) {
            
            var remoteData: Data?
            
            do {
                let remoteURL = URL(string: urlString)
                
                if remoteURL != nil {   remoteData = try Data(contentsOf: remoteURL!, options: Data.ReadingOptions.mappedIfSafe)    }
                else                {   remoteData = nil    }
            }
            catch {
                remoteData = nil
            }
            
            // Hide the activity indicator and pass the Data to the closure (in the main queue)
            DispatchQueue.main.async {
                
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                
                completion(remoteData)
            }
        }
        
    }
    
    
    // Re-scales a given UIImage to fit inside the the given CGSize (the image keeps its aspect ratio)
    // (based on code from https://iosdevcenters.blogspot.com/2015/12/how-to-resize-image-in-swift-in-ios.html)
    class func resizeImage(_ image: UIImage, toSize targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    // Gets the device screen size
    class func screenSize() -> CGSize {
        
        return UIScreen.main.nativeBounds.size
    }
    
    
    // Converts an NSData date to a String
    class func dateToString(_ date: NSDate) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        
        return formatter.string(from: date as Date)
    }
}
