//
//  Cover+CoreDataProperties.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData


extension Cover {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cover> {
        return NSFetchRequest<Cover>(entityName: "Cover");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var url: String?
    @NSManaged public var book: Book?

}
