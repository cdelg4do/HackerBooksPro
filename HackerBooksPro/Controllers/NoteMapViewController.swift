//
//  NoteMapViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 06/10/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import MapKit


class NoteMapViewController: UIViewController {
    
    //MARK: Propiedades
    var currentNote: Note
    
    // Referencia a los objetos de la interfaz
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: Inicializadores

    init(currentNote: Note) {
        
        self.currentNote = currentNote
        
        super.init(nibName: "NoteMapViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // Ciclo de vida del controlador
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Añadimos al mapa el objeto que cumple con el protocolo MKAnnotation (la nota actual)
        mapView.addAnnotation(currentNote)
        
        // Indicamos al mapViewq -que implmenta el protocolo MKMapViewDelegate- cuál será su delegado
        // (para poder personalizar las propiedades de la anotación: color, etc)
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Centrar la vista del mapa en la nota, mostrando un área alrededor
        // En dos tiempos, primero una animación que centra la vista con un radio de 1.000 Km
        // Después, otra anmación que amplía la vista hasta un radio de 2 Km
        
        let bigRegion = MKCoordinateRegionMakeWithDistance(self.currentNote.coordinate, 1000000, 1000000)
        let smallRegion = MKCoordinateRegionMakeWithDistance(self.currentNote.coordinate, 2000, 2000)
        
        var delayInNanoSeconds = UInt64(1) * NSEC_PER_SEC
        var time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            self.mapView.setRegion(bigRegion, animated: true)
            
            delayInNanoSeconds = UInt64(1) * NSEC_PER_SEC
            time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                
                self.mapView.setRegion(smallRegion, animated: true)
            })
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Note at page \(currentNote.page)"
    }
    
    
    
    //MARK: Acciones a realizar al pulsar los botones del mapa
    
    @IBAction func showMapView(_ sender: AnyObject) {
        
         mapView.mapType = .standard
    }
    
    
    @IBAction func showSatelliteView(_ sender: AnyObject) {
        
         mapView.mapType = .satellite
    }
    
    
    @IBAction func showHybridView(_ sender: AnyObject) {
        
        mapView.mapType = .hybrid
    }

}



// Implementación del protocolo de delegado de MKMapView
// (para poder personalizar las anotaciones que se muestran en el mapa)

extension NoteMapViewController: MKMapViewDelegate {
    
    // El MapView funciona similar a una TableView, reciclando anotaciones
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "MyNote"
        
        // Forzamos el cast porque sino devuelve la superclase MKAnnotationView
        // (y en caso de ser nil, nos interesa configurarla como MKPinAnnotationView)
        var noteView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if noteView == nil {
            
            // La creamos de cero, y le asignamos el color púrpura
            noteView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            noteView?.pinTintColor = MKPinAnnotationView.purplePinColor()
            
            // Al ser una anotación personalizada se le indica explícitamente que muestre el callout al ser pulsada
            noteView?.canShowCallout = true
            
            // Personalización del callout (miniatura de la imagen de la nota)
            var thumbnail: UIImage
            let thumbnailSize = CGSize(width: 50, height: 50)
            
            if currentNote.photo?.image != nil {
                thumbnail = Utils.resizeImage((currentNote.photo?.image)!, toSize: thumbnailSize)
            }
            else {
                thumbnail = Utils.resizeImage(UIImage(named: "note_icon.png")!, toSize: thumbnailSize)
            }
            
            noteView?.leftCalloutAccessoryView = UIImageView(image: thumbnail)
        }
        
        return noteView
    }
    
}






