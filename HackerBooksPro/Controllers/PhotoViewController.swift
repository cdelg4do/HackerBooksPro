//
//  PhotoViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 02/10/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSManagedObjectContext


class PhotoViewController: UIViewController {
    
    //MARK: Propiedades de la clase
    
    var currentNote: Note
    var context: NSManagedObjectContext
    
    var saveShownImage = false   // si se muestra la imagen por defecto, no debe guardarse en el modelo
    
    // Referencia a los elementos de la interfaz
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    //MARK: Inicializadores de la clase
    init(currentNote: Note, context: NSManagedObjectContext) {
        
        self.currentNote = currentNote
        self.context = context
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // Inicializador necesario por la herencia de Objetctive-C en Swift
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Ciclo de vida del controlador
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Acciones a realizar justo antes de mostrar el controlador
    // (cargar los datos del modelo en la vista)
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        syncViewFromModel()
    }
    
    // Acciones a realizar justo antes de dejar de mostrar el controlador
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        syncModelFromView()
    }
    
    
    // Mostrar en la vista los datos del modelo
    func syncViewFromModel() {
        
        let imageShowing: UIImage
        
        if currentNote.photo?.image != nil {
            
            imageShowing = (currentNote.photo?.image)!
            deleteButton.isEnabled = true
            
            saveShownImage = true
        }
        else {
            imageShowing = UIImage(named: "no_image.png")!
            deleteButton.isEnabled = false
            
            saveShownImage = false
        }
        photoView.image = Utils.resizeImage(imageShowing, toSize: Utils.screenSize() )
        
        title = "Note at page \(currentNote.page)"
    }
    
    // Guardar en el modelo la información de la vista
    func syncModelFromView() {
        
        if saveShownImage {
            currentNote.photo?.image = photoView.image
        }
    }
    
    
    // Acción a realizar cuando se pulse el botón de imagen
    @IBAction func chooseImage(_ sender: AnyObject) {
        
        // Configuración del selector de imágenes
        let picker = UIImagePickerController()
        
        /*
         // Acceso a la cámara si está disponible, o bien a la galería.
         // (deben incluirse en el info.plist valores para "Privacy - Camera Usage Description"
         // y para "Privacy - Photo Library Usage Description", respectivamente)
         
         if UIImagePickerController.isCameraDeviceAvailable(.rear) {
         picker.sourceType = .camera
         }
         else {
         picker.sourceType = .photoLibrary
         }
         */
        
        // Acceso directamente a la galería
        picker.sourceType = .photoLibrary
        
        // Especificar su delegado para las acciones a realizar con la imagen escogida (este mismo controlador)
        picker.delegate = self
        
        // Mostrarlo de forma modal
        self.present(picker, animated: true) {
            // Acciones a realizar nada más mostrarse el picker
        }
    }
    
    
    // Acción a realizar cuando se pulse el botón de borrar foto
    @IBAction func deleteImage(_ sender: AnyObject) {
        
        // Guardamos los bounds originales de la imagen
        let initialBounds = self.photoView.bounds
        
        // Hacer desaparecer la imagen con una animación
        // (a lo largo de 0,9 segundos reducirá la transparencia hasta 0,
        // y centrado en el medio de la imagen aplicará una rotación de PI cuartos en radianes)
        UIView.animate(withDuration: 0.9,
                       animations: {
                        self.photoView.alpha = 0
                        self.photoView.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                        self.photoView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            })
        {
            
            (finished: Bool) in
            
            // Una vez desaparecida, restaurar los parámetros originales de la UIImageView
            self.photoView.bounds = initialBounds
            self.photoView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            self.photoView.alpha = 1
            
            // Eliminamos la imagen del modelo y sincronizamos la vista
            // (lo hacemos dentro de este bloque de finalización para esperar a que acabe la animación)
            self.currentNote.photo?.image = nil
            self.syncViewFromModel()
            
            // Se mostrará la imagen por defecto, que en ningún caso debe guardarse en el modelo
            self.saveShownImage = false
        }
    }
    
    
}



// Implementación de los protocolos de delegado de UIImagePickerController y de UINavigationController

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Acción a realizar cuando se escoge una imagen
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Redimensionar la imagen escogida antes de mostrarla, para evitar problemas de memoria
        let screenSize = UIScreen.main.nativeBounds.size
        let resizedImage = Utils.resizeImage(pickedImage, toSize: screenSize )
        
        // Actualizar el modelo
        // (la vista se actualizará cuando se muestre el PhotoViewController, una vez retirado el picker)
        currentNote.photo?.image = resizedImage
        
        // Si se sigue mostrando esta imagen al salir de este controlador, se salvará en el modelo
        saveShownImage = true
        
        // Eliminar el UIImagePickerController
        self.dismiss(animated: true) {}
    }
}

