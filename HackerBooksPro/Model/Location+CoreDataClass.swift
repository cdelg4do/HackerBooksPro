//
//  Location+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData
import CoreLocation


// This class represents a location in the system

@objc(Location)
public class Location: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Location"
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(location: CLLocation, forNote note: Note, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Location.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        addToNote(note)
        
        // Get the address for that coordinates
        print("\nResolving address for the coordinates (lat: \(self.latitude), long: \(self.longitude)...\n")
        let coder = CLGeocoder()
        
        coder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            self.address = "<Unknown address>"
            
            if error != nil {
                print("\nERROR: Unable to resolve address for those coordinates\n" + (error?.localizedDescription)!)
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.last {
                
                if let lines: Array<String> = placemark.addressDictionary?["FormattedAddressLines"] as? Array<String> {
                    
                    self.address = lines.joined(separator: ", ")
                }
                else {
                    print("\nERROR: Unable to resolve address for those coordinates\n")
                    return
                }
            }
            else {
                print("\nERROR: Unable to resolve address for those coordinates\n")
                return
            }
        })
    }
}

