//
//  ViewController.swift
//  PetClassifier
//
//  Created by Brandon Mahoney on 3/3/19.
//  Copyright © 2019 Brandon Mahoney. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Properties
    let imagePicker: UIImagePickerController = UIImagePickerController()
    
    
    //MARK: - outlets
    @IBOutlet weak var imageView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    
    //MARK: - Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError("Could not convert UIImage into CIImage.") }
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: PetClassifier().model) else { fatalError("Loading CoreML Model failed.") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else { fatalError("Model failed to process image.") }
            
            self.navigationItem.title = classification.identifier.capitalized
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }

    
    //MARK: - Actions
    @IBAction func barButtonItemTapped(_ sender: UIBarButtonItem) {
        if sender.tag == 1 {
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
            imagePicker.showsCameraControls = true
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
}

