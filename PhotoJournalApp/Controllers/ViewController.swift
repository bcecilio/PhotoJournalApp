//
//  ViewController.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/23/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit
import AVFoundation

protocol EditPostDelegate {
    func editButtonPressed(_ imageView: ViewController)
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var images = [ImageObject](){
        didSet{
            self.collectionView.reloadData()
        }
    }
    private var imagePickerController = UIImagePickerController()
    private var imagePersistance = PersistenceHelper(filename: "images.plist")
    private var selectedImages : UIImage? 
    private var newText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        collectionView.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePickerController.delegate = self
        loadImages()
    }
    
    private func loadImages() {
        do {
            images = try imagePersistance.loadImages()
        } catch {
            print("loading error: \(error)")
        }
    }
    
    @IBAction func optionsButtonPressed(_ sender: UIButton) {
        let optionsController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .default)
        let editAction = UIAlertAction(title: "Edit", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionsController.addAction(editAction)
        optionsController.addAction(deleteAction)
        optionsController.addAction(cancelAction)
        present (optionsController, animated: true)
    }
    
    @IBAction func addImageToCollection() {
        addImage()
    }
    
    private func addImage() {
        guard let addImageVC = storyboard?.instantiateViewController(identifier: "UploadPostController") as? UploadPostController else {
            return
        }
        addImageVC.delegate = self
        present(addImageVC, animated: true)
    }
    
    private func showImageController(isCameraSelected: Bool) {
        imagePickerController.sourceType = .photoLibrary
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError("could not downcast ImageCollectionViewCell")
        }
        let cellImage = images[indexPath.row]
        cell.configureCell(imageObject: cellImage)
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.90
        return CGSize(width: itemWidth, height: 450)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // we nee to access the UIImagePickerController.InfoKey.originalImage key to get the UIImage that was seclected
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selection not found")
            return
        }
        selectedImages = image
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension ViewController: ImageCellDelegate {
    func didLongPress(_ imageCell: ImageCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        // need to present an action sheet
        
        // action: delete, cancel
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] alertAction in self?.deleteImageObject(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func deleteImageObject(indexPath: IndexPath) {
        // delete image object from documents directory
        imagePersistance.reorderImages(image: images)
        do {
            images = try imagePersistance.loadImages()
        } catch {
            print("loading error: \(error)")
        }
        // delete imageObject from imageObjects
        images.remove(at: indexPath.row)
        // delete cell from collectionView
        collectionView.deleteItems(at: [indexPath])
        
        do {
            try imagePersistance.delete(item: indexPath.row)
        } catch {
            print("error deleting item: \(error)")
        }
    }
}

extension ViewController: UploadImageDelegate {
    
    func uploadedPost(_ imageView: ImageObject) {
        self.images.append(imageView)
    }
}

extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
