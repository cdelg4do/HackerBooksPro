//
//  Note+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData
import CoreLocation
import MapKit       // to use the MKAnnotation protocol


// This class represents a note in the system

@objc(Note)
public class Note: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Note"
    
    let locationManager = CLLocationManager()
    
    // Calculated variable that indicates whether the note has a location or not
    var hasLocation: Bool {
        
        get {   return self.location != nil   }
    }
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(book: Book, page: Int32, minContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Note.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.book = book
        self.page = page
        self.creationDate = NSDate()
        self.modificationDate = NSDate()
        
        // Create an empty photo object, and store it in the note
        self.photo = Photo(note: self, inContext: context)
    }
    
    
    // This method is invoked by all NSManagedObects the first time they are created
    // (we override it to assign the current location to the new note)
    override public func awakeFromInsert() {
        
        let status = CLLocationManager.authorizationStatus()
        
        // If the location service is authorized and enabled, start receiving geolocation data
        if (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.notDetermined)
            && CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self                 // Delegate must implement CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()    // set "Privacy - Location Always Usage Description" in Info.plist
            locationManager.startUpdatingLocation()
            
            // Dispose the location manager after 5 seconds (to save battery)
            let delayInNanoSeconds = UInt64(5) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.disposeLocationManager() } )
        }
    }
    
    
    // Auxiliary function to stop and remove the locationManager
    func disposeLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
}


//MARK: implementation of CLLocationManagerDelegate protocol --> how to process the locations received
    
extension Note: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Dispose the location manager to save battery
        disposeLocationManager()
        
        // If the note already had a location, do nothing
        if self.hasLocation {   return  }
        
        // If not, get the last location received, create a new location object and assign to the note
        let lastLocation = locations.last!
        let _ = Location(location: lastLocation, forNote: self, inContext: self.managedObjectContext!)
    }
}


// Implementation of MKAnnotation --> to represent the note in a map

extension Note: MKAnnotation {
    
    // Coordinates to locate the annotation in the map (from the note location)
    public var coordinate: CLLocationCoordinate2D {
        
        get {
            if self.hasLocation {
                let lat = self.location!.latitude
                let long = self.location!.longitude
                return CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
            else {
                return CLLocationCoordinate2D()
            }
        }
    }
    
    // Title for the annotation (to show in the callout when the user clicks on the location pin): the note text
    public var title: String? {
        
        get {
            var annotationTitle = self.text
            
            // If the annotation title is an empty string, the callout view will never show,
            // so we always need to return a non-empty string here
            if (annotationTitle?.isEmpty)! {
                annotationTitle = "<No text>"
            }
            
            return annotationTitle
        }
    }
    
    // Subtitle for the annotation in the map (to show in the callout): the note creation date
    public var subtitle: String? {
        
        get {
            return Utils.dateToString(self.creationDate!)
        }
    }
    
}






