//
//  Note+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData

import CoreLocation

@objc(Note)
public class Note: NSManagedObject {
    
    // Nombre que corresponde a la entidad de esta clase en el modelo
    static let entityName = "Note"
    
    let locationManager = CLLocationManager()
    
    // Propiedad computada que indica si la nota tiene una ubicación asociada
    var hasLocation: Bool {
        
        get {   return self.location != nil   }
    }
    
    // Inicializador de la clase
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(book: Book, page: Int32, minContext context: NSManagedObjectContext) {
        
        // Obtenemos la entidad correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Note.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar valores iniciales a las propiedades
        self.book = book
        self.page = page
        self.creationDate = NSDate()
        self.modificationDate = NSDate()
        
        // Creamos una imagen vacía y la guardamos en la nota
        self.photo = Photo(note: self, inContext: context)
    }
    
    
    // Método que ejecuta todo NSManagedObject cuando se crea por primera vez
    override public func awakeFromInsert() {
        
        let status = CLLocationManager.authorizationStatus()
        
        // Si el servicio de localización está activado y autorizado,
        // empezamos a recibir datos de geolocalización
        if (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.notDetermined) && CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()    // definir "Privacy - Location Always Usage Description" en el Info.plist
            locationManager.startUpdatingLocation()
            
            // Eliminar el locationManager tras 5 segundos
            let delayInNanoSeconds = UInt64(5) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.disposeLocationManager() } )
        }
    }
    
    
    //MARK: Utils
    
    // Función que detiene y elimina el locationManager
    func disposeLocationManager() {
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
}



// Implementación del protocolo de delegado de CLLocationManager
    
extension Note: CLLocationManagerDelegate {
    
    // Tratamiento de las ubicaciones recibidas desde el location manager
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Parar de recibir actualizaciones de ubicación (para ahorrar batería)
        disposeLocationManager()
        
        // Si la nota ya tenía una localización, no hacemos nada
        if self.hasLocation {   return  }
        
        // Obtener la última localización
        let lastLocation = locations.last!
        
        // Crear la localización y asignarla a la nota
        let _ = Location(location: lastLocation, forNote: self, inContext: self.managedObjectContext!)
    }
}






