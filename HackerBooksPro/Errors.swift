//
//  Errors.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation


// This file contains the definition of errors that can be thrown during the execution
// (all derived from Error, so that they can be returned with throw)


//MARK: errors that can be thrown while processing a JSON file

enum JsonError: Error {
    
    case wrongURLFormatForJSONResource
    case resourcePointedByURLNotReachable
    case jsonParsingError
    case wrongJSONFormat
    case nilJSONObject
    case unableToWriteJSONFile
    case unableToGetDataFromRemoteJson
}


//MARK: errors that can be thrown while accessing the file system

enum FilesystemError: Error {
    
    case unableToCreateCacheFolders
}


//MARK: errors that can be thrown while accessing the SQLite data

enum CoreDataError: Error {
    
    case fetchRequestFailure
}
