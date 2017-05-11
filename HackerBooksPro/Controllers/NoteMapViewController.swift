//
//  NoteMapViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 06/10/16.
//

import UIKit
import MapKit


// This class is the view controller to show a map with a note location

class NoteMapViewController: UIViewController {
    
    var currentNote: Note
    
    // Reference to UI elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBtn: UIBarButtonItem!
    @IBOutlet weak var satelliteViewBtn: UIBarButtonItem!
    @IBOutlet weak var hybridViewBtn: UIBarButtonItem!
    
    //MARK: Initializers

    init(currentNote: Note) {
        
        self.currentNote = currentNote
        
        super.init(nibName: "NoteMapViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // Controller lifecycle events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add to the map an object that implements the MKAnnotation protocol (the note itself)
        mapView.addAnnotation(currentNote)
        
        // Set the map delegate (implements the MKMapViewDelegate) as itself
        // (to configure the annotation properties: color, etc)
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Center the map view around the note location:
        // - First, use an animation to center the view in an area of 1,000 x 1,000 km
        // - Next, use an animation to zoom in till a radius of 2 x 2 km
        
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

        title = "Location for note at page \(currentNote.page)"
        
        mapViewBtn.isEnabled = false
        satelliteViewBtn.isEnabled = true
        hybridViewBtn.isEnabled = true
    }
    
    
    // Actions from the UI elements
    
    // 'Map' button
    @IBAction func showMapView(_ sender: AnyObject) {
        
        mapView.mapType = .standard
        
        mapViewBtn.isEnabled = false
        satelliteViewBtn.isEnabled = true
        hybridViewBtn.isEnabled = true
    }
    
    // 'Satellite' button
    @IBAction func showSatelliteView(_ sender: AnyObject) {
        
        mapView.mapType = .satellite
        
        mapViewBtn.isEnabled = true
        satelliteViewBtn.isEnabled = false
        hybridViewBtn.isEnabled = true
    }
    
    // 'Hybrid' button
    @IBAction func showHybridView(_ sender: AnyObject) {
        
        mapView.mapType = .hybrid
        
        mapViewBtn.isEnabled = true
        satelliteViewBtn.isEnabled = true
        hybridViewBtn.isEnabled = false
    }
}


//MARK: Implementation of the MKMapViewDelegate protocol (to configure the map annotations)

extension NoteMapViewController: MKMapViewDelegate {
    
    // The MapView works like a TableView, recycling annotations
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "MyNote"
        
        // The function dequeueReusableAnnotationView() returns the superclass MKAnnotationView
        // (but we will use the sublclass MKPinAnnotationView on our map, so use the as? to downcast it)
        var noteView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if noteView == nil {
            
            // Create the annotation as a MKPinAnnotationView
            // (a configurable type of MKAnnotationView that displays a pin icon on the map)
            noteView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            // Set the pin color and set the callout to show when the user touches the pin
            noteView?.pinTintColor = MKPinAnnotationView.purplePinColor()
            noteView?.canShowCallout = true
            
            // Callout setup: show a thumbnail of the note image (use the default image if needed)
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






