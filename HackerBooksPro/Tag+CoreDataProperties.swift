//
//  Tag+CoreDataProperties.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag");
    }

    @NSManaged public var name: String?
    @NSManaged public var proxyForSorting: String?
    @NSManaged public var bookTags: NSSet?

}

// MARK: Generated accessors for bookTags
extension Tag {

    @objc(addBookTagsObject:)
    @NSManaged public func addToBookTags(_ value: BookTag)

    @objc(removeBookTagsObject:)
    @NSManaged public func removeFromBookTags(_ value: BookTag)

    @objc(addBookTags:)
    @NSManaged public func addToBookTags(_ values: NSSet)

    @objc(removeBookTags:)
    @NSManaged public func removeFromBookTags(_ values: NSSet)

}
