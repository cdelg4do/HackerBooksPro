//
//  PhotoViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 02/10/16.
//

import UIKit
import CoreData     // to use NSManagedObjectContext


// This class is the view controller to show the note image
// (and the controls to remove/pick a new one)

class PhotoViewController: UIViewController {
    
    var currentNote: Note
    var context: NSManagedObjectContext
    var saveShownImage = false  // flag that indicates if the selected image should be saved to the model
                                // (if the selected image is the default one, then it will be false)
    
    // Reference to UI elements
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    //MARK: Initializators
    init(currentNote: Note, context: NSManagedObjectContext) {
        
        self.currentNote = currentNote
        self.context = context
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: controller lifecycle evetnts
    
    // What to do after the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // What to do just before show the controller
    // (update the view from the model data)
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        syncViewFromModel()
    }
    
    // What to do just before the controller is not shown any longer
    // (save the data in the view to the model)
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        syncModelFromView()
    }
    
    
    // MARK: auxiliary functions
    
    // Update the view from the model data
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
        
        title = "Image for note at page \(currentNote.page)"
    }
    
    // Save the data in the view to the model
    func syncModelFromView() {
        
        if saveShownImage {
            currentNote.photo?.image = photoView.image
        }
    }
    
    
    //MARK: Actions from the UI elements
    
    // 'Pick from gallery' button -> open the device gallery to select a picture
    @IBAction func chooseImage(_ sender: AnyObject) {
        
        // Setup image picker
        let picker = UIImagePickerController()
        
        // Direct access to the gallery
        // (requires to add in info.plist a value for "Privacy - Photo Library Usage Description")
        picker.sourceType = .photoLibrary
        
        /*
         // Uncomment this block if you want to try the camera first.
         // If the camera is not available, then go to the gallery
         // (requires to add in info.plist a value for "Privacy - Camera Usage Description")
         
         if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            picker.sourceType = .camera
         }
         else {
            picker.sourceType = .photoLibrary
         }
        */
        
        // Set this controller as the picker delegate (should implement the 
        // UIImagePickerControllerDelegate and UINavigationControllerDelegate protocols) and show it in modal way
        picker.delegate = self
        self.present(picker, animated: true) {
            // Here goes the actions to perform right after showing the picker, if any
        }
    }
    
    // 'Remove Image' button -> remove the current image from the note
    @IBAction func deleteImage(_ sender: AnyObject) {
        
        // Save the original bounds of the current image on screen
        let initialBounds = self.photoView.bounds
        
        // Make the current image disappear using an animation that takes 0.9 seconds
        // (the alpha will fade to transparent, while the image rotates Pi radians centered in the middle)
        UIView.animate(withDuration: 0.9,
                       animations: {
                        self.photoView.alpha = 0
                        self.photoView.bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
                        self.photoView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
                       })
        { (finished: Bool) in
            
            // Once the animation is finished restore the original image bounds, rotation and alpha
            self.photoView.bounds = initialBounds
            self.photoView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            self.photoView.alpha = 1
            
            // Remove the image from the model, then sync the view
            // (will show the default image, that should never be saved to the model)
            self.currentNote.photo?.image = nil
            self.syncViewFromModel()
            self.saveShownImage = false
        }
    }
}


//MARK: class extensions (implementation of the UIImagePickerController delegate protocols)

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // What to do when an image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get the selected image and re-escale it to fit into the screen (to prevent memory overload)
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let screenSize = UIScreen.main.nativeBounds.size
        let resizedImage = Utils.resizeImage(pickedImage, toSize: screenSize )
        
        // Update the model with the resized image (the view will update automatically after the picker is gone)
        // Set the save flag to true (to save in the model the image shown when we quit from this controller)
        currentNote.photo?.image = resizedImage
        saveShownImage = true
        
        // Last, dismiss the image picker
        self.dismiss(animated: true) {}
    }
}

