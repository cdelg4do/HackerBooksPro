//
//  Utils.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation

import UIKit


class Utils {
    
    // Clausuras de finalización, funciones que reciben un UIImage? o un Data?
    // y que se ejecutarán siempre en la cola principal
    
    typealias imageClosure = (UIImage?) -> ()
    typealias dataClosure = (Data?) -> ()
    
    
    // Función que realiza la descarga de una imágen remota en segundo plano
    // Si la descarga se realiza con éxito, produce la UIImage resultante.
    // Si no, produce nil.
    // 
    // Parámetros:
    // 
    // - fromUrl: cadena con la url de la imagen remota
    // - mustResize: indica si la imagen debe redimensionarse al tamaño de la pantalla (true) o quedar en su tamaño original (false)
    // - activityIndicator: activa y desactiva el indicador de actividad antes y después de la operación asíncrona (si no se usa, dejar a nil)
    // - completion: clausura de finalización que recibe un UIImage? resultante, que se ejecutará en la cola principal
    
    class func asyncDownloadImage(fromUrl urlString: String, mustResize: Bool, activityIndicator: UIActivityIndicatorView?, completion: @escaping imageClosure) {
        
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        // Carga de datos y confección de la imagen (en segundo plano)
        //DispatchQueue.global(qos: .userInitiated).async {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(1) ) {
            
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
            
            // Pasar la imagen obtenida a la clausura de finalización (en la cola principal)
            DispatchQueue.main.async {
                
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                
                completion(finalImage)
            }
        }
        
    }
    
    
    // Función que realiza la descarga de datos de una URL remota en segundo plano
    // Si la descarga se realiza con éxito, produce el Data resultante.
    // Si no, produce nil.
    //
    // Parámetros:
    //
    // - fromUrl: cadena con la url remota
    // - activityIndicator: activa y desactiva el indicador de actividad antes y después de la operación asíncrona (si no se usa, dejar a nil)
    // - completion: clausura de finalización que recibe un Data? resultante, que se ejecutará en la cola principal
    
    class func asyncDownloadData(fromUrl urlString: String, activityIndicator: UIActivityIndicatorView?, completion: @escaping dataClosure) {
        
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        
        // Carga de datos (en segundo plano)
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
            
            // Pasar los datos obtenidos a la clausura de finalización (en la cola principal)
            DispatchQueue.main.async {
                
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                
                completion(remoteData)
            }
        }
        
    }
    
    
    // Función que re-escala una imagen, para que entre dentro del CGSize indicado
    // (la imagen resultante mantiene su proporción original)
    // (ver https://iosdevcenters.blogspot.com/2015/12/how-to-resize-image-in-swift-in-ios.html)
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
    
    
    // Función que indica el tamaño de la pantalla del dispositivo
    class func screenSize() -> CGSize {
        
        return UIScreen.main.nativeBounds.size
    }
    
    // Función que convierte un objeto NSDate a la correspondiente cadena de texto
    class func dateToString(_ date: NSDate) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        
        return formatter.string(from: date as Date)
    }
    
}

