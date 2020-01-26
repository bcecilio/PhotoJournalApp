//
//  UploadPostController.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/26/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit
import AVFoundation

protocol UploadImageDelegate {
    func didLongPress(_ imageView: UploadPostController)
}

class UploadPostController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    private var imagePickerController = UIImagePickerController()
    private var imagePersistance = PersistenceHelper(filename: "images.plist")
    private var images = [ImageObject]()
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        imagePickerController.delegate = self
        textView.layer.cornerRadius = 7
        loadImageObjects()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        showImageController(isCameraSelected: true)
    }
    
    @IBAction func accessPhotoLibraryPressed(_ sender: UIBarButtonItem) {
        showImageController(isCameraSelected: false)
    }
    
    private func loadImageObjects() {
        do {
            images = try imagePersistance.loadImages()
        } catch {
            print("loading objects error: \(error)")
        }
    }
    
    private func showImageController(isCameraSelected: Bool) {
        imagePickerController.sourceType = .photoLibrary
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
}

extension UploadPostController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selection not found")
            return
        }
        imageView.image = chosenImage
        dismiss(animated: true)
    }
}
