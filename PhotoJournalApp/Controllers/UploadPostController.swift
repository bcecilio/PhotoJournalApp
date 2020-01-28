//
//  UploadPostController.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/26/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit
import AVFoundation

protocol UploadImageDelegate: AnyObject {
    func uploadedPost(_ imageView: ImageObject)
}

class UploadPostController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: UploadImageDelegate?
    private var imagePickerController = UIImagePickerController()
    private var imagePersistance = PersistenceHelper(filename: "images.plist")
    private var images: ImageObject?
    public var selectedImage: UIImage?
    public var postText: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        imagePickerController.delegate = self
        textView.text = "Add text to your Post!"
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        textView.layer.cornerRadius = 7
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        showImageController(isCameraSelected: true)
    }
    
    @IBAction func accessPhotoLibraryPressed(_ sender: UIBarButtonItem) {
        showImageController(isCameraSelected: false)
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIBarButtonItem) {
        uploadImage()
    }
    
    private func uploadImage() {
        guard let photo = imageView.image else {
            return
        }
        
        let size = UIScreen.main.bounds.size
        
        let rect = AVMakeRect(aspectRatio: photo.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        guard let resized = photo.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        images = ImageObject(imageData: resized, date: Date(), description: textView.text!)
        delegate?.uploadedPost(images!)
        dismiss(animated: true)
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

extension UploadPostController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {

            textView.text = "Add text to your Post!"
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
         else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}
