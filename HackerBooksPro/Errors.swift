//
//  Errors.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation


// MARK: JSON Errors

// Definiciones de los diferentes errores
// (derivados de Error para poder devolverlos con un throw)

enum JsonError: Error {
    
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
    case unableToWriteJSONFile
    case unableToGetDataFromRemoteJson
}


enum FilesystemError: Error {
    
    case unableToCreateCacheFolders
}


enum CoreDataError: Error {
    
    case fetchRequestFailure
}
